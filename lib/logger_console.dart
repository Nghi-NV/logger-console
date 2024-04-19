/// Created by nghinv on Tue Jun 07 2022

library logger_console;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nghinv_device_info/nghinv_device_info.dart';
import 'package:socket_channel/web_socket_channel.dart';

part 'logger_argument.dart';
part 'log_trace.dart';
part '_model.dart';

class Console {
  static WebSocketChannel? _channel;
  static String? _channelId;

  /// Identify of device
  static get channelId => _channelId;

  /// host socket
  static String host = "localhost";

  /// port socket
  static int port = 9090;

  /// enable [Console.log()]
  ///
  /// default = true when run in debug mode
  /// default = false when run in release mode
  static bool enableLog = kDebugMode ? true : false;

  /// when _uri != null, use uri to connect socket
  static String? _uri;

  static String? get uri => _uri;

  /// tag for log
  /// * = all tag
  static List<String> tags = ['*'];

  /// check contains tag
  /// return true if tags contains '*' or contains tag
  static bool hasTag(String tag) {
    return tags.contains('*') || tags.contains(tag);
  }

  static bool logTrace = false;

  static Function(List<dynamic> messages, LogType logType)? _logListener;

  static void setLogListener(
      Function(List<dynamic> messages, LogType logType)? listener) {
    _logListener = listener;
  }

  static ClientInfo? clientInfo;

  static WebSocketChannel? getInstance() {
    if (_channel == null) {
      _connectServer();
    }

    return _channel;
  }

  static Uri getUri() {
    String uriString = "ws://$host:$port";
    if (_uri != null) {
      uriString = _uri!;
    }

    return Uri.parse(uriString);
  }

  static void setUri(String? uri) {
    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (e) {
        //
      }
      _channel = null;
    }

    _uri = uri;
  }

  /// Get device info
  static Future _getDeviceInfo() async {
    final deviceInfo = await NDeviceInfo().getDeviceInfo();
    clientInfo = ClientInfo(
      id: deviceInfo?.id ?? Platform.localHostname,
      name: (deviceInfo?.name == "iPhone"
              ? deviceInfo?.model
              : deviceInfo?.name) ??
          Platform.localHostname,
      platform: deviceInfo?.os ?? Platform.operatingSystem,
      version: deviceInfo?.version ?? Platform.operatingSystemVersion,
      os: deviceInfo?.os ?? (kIsWeb ? 'Web' : Platform.operatingSystem),
      osVersion: kIsWeb ? 'Web' : Platform.operatingSystem,
      language: kIsWeb ? null : Platform.localeName,
      userAgent: deviceInfo?.userAgent,
      timeZone: DateTime.now().timeZoneName,
      isSimulator: deviceInfo?.isSimulator ?? false,
      buildVersion: deviceInfo?.buildVersion ?? Platform.version,
      model: deviceInfo?.model,
      manufacturer: deviceInfo?.manufacturer,
    );
  }

  static _connectServer([String? data]) async {
    try {
      _channel = WebSocketChannel.connect(getUri());
    } catch (error) {
      return;
    }

    _channel!.ready.then((_) {
      _channel!.stream.listen(
        (event) {},
        onDone: () {
          _channel = null;
        },
        onError: (error) {
          _channel = null;
        },
        cancelOnError: true,
      );
    }).onError((error, stackTrace) {
      _channel = null;
    });

    if (_channel == null) {
      return;
    }

    if (data != null) {
      _channel!.sink.add(data);
    }
  }

  static dynamic _logBase(List<dynamic> args,
      [LogType type = LogType.log]) async {
    if (!enableLog) return;

    if (_logListener != null) {
      _logListener!(args, type);
    }

    if (clientInfo == null) {
      await _getDeviceInfo();
    }

    final payloadData = {
      "clientInfo": clientInfo,
      "data": args,
    };

    final payload = _PayloadData(data: json.encode(payloadData));
    final dataRequest = _RequestData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      logType: type,
      secure: payload.encryptionKey != null,
      payload: payload,
    );

    if (_channel == null) {
      _connectServer(json.encode(dataRequest.toJson()));
      return;
    }

    if (_channel!.closeCode != null) {
      _channel = null;
      _connectServer(json.encode(dataRequest.toJson()));
      return;
    }

    _channel!.sink.add(json.encode(dataRequest.toJson()));
  }

  /// Send log to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// Console.log({
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  ///
  /// Console.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  ///
  /// Console.log(json.decode(response));
  /// ```
  static dynamic log = _VarArgsFunction((args) {
    _logBase(args);
  });

  /// Send log group to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// Console.group("Group 1");
  /// Console.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  /// Console.groupEnd();
  /// ```
  static dynamic group = _VarArgsFunction((args) {
    _logBase(args, LogType.group);
  });

  /// Send log group collapsed to [Server Log] app
  ///
  /// Example:
  /// ```dart
  /// Console.groupCollapsed("Group 1");
  /// Console.log("data", {
  ///   "name": "alex",
  ///   "old": 12,
  /// });
  /// Console.groupEnd();
  /// ```
  static dynamic groupCollapsed = _VarArgsFunction((args) {
    _logBase(args, LogType.groupCollapsed);
  });

  /// End log group or collapsed group
  static dynamic groupEnd = _VarArgsFunction((args) {
    _logBase(args, LogType.groupEnd);
  });

  /// Send log info to [Server Log] app
  static dynamic info = _VarArgsFunction((args) {
    _logBase(args, LogType.info);
  });

  /// Send log warn to [Server Log] app
  static dynamic warn = _VarArgsFunction((args) {
    _logBase(args, LogType.warn);
  });

  /// Send log error to [Server Log] app
  static dynamic error = _VarArgsFunction((args) {
    _logBase(args, LogType.error);
  });

  static dynamic clear = _VarArgsFunction((args) {
    _logBase(args, LogType.clear);
  });

  static dynamic count = _VarArgsFunction((args) {
    _logBase(args, LogType.count);
  });

  static dynamic countReset = _VarArgsFunction((args) {
    _logBase(args, LogType.countReset);
  });

  /// Bloc to log
  ///
  /// [Bloc event]
  /// ```dart
  /// abstract class ExampleEvent extends BlocBaseEvent {}
  ///
  /// class ExampleEventAdd extends ExampleEvent {
  ///   final ExampleState exampleState;
  ///
  ///   ExampleEventAdd(this.exampleState);
  ///
  ///   @override
  ///   eventToPayload() {
  ///     return exampleState.toJson();
  ///   }
  ///
  ///   @override
  ///   List<Object?> get props => [exampleState];
  /// }
  /// ```
  ///
  /// [BlocObserver]
  /// ```dart
  /// import 'package:flutter_bloc/flutter_bloc.dart';
  /// import 'package:logger/logger.dart';
  ///
  /// class AppBlocObserver extends BlocObserver {
  ///   @override
  ///   void onTransition(Bloc bloc, Transition transition) async {
  ///     super.onTransition(bloc, transition);
  ///     String eventType = transition.event.runtimeType.toString();
  ///     var currentState;
  ///     var nextState;
  ///     var eventPayload;
  ///
  ///     try {
  ///       currentState = transition.currentState.map((e) => e.toJson()).toList();
  ///     } catch (e) {
  ///       currentState = transition.currentState.toString();
  ///     }
  ///     try {
  ///       nextState = transition.nextState.map((e) => e.toJson()).toList();
  ///     } catch (e) {
  ///       nextState = transition.nextState.toString();
  ///     }
  ///     try {
  ///       eventPayload = transition.event.eventToPayload();
  ///     } catch (e) {
  ///       eventPayload = transition.event.toString();
  ///     }
  ///
  ///     Console.logBloc(
  ///       currentState,
  ///       nextState,
  ///       BlocEvent(type: eventType, payload: eventPayload),
  ///     );
  ///   }
  ///
  ///   @override
  ///   void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
  ///     super.onError(bloc, error, stackTrace);
  ///     Console.log('onError', error);
  ///   }
  /// }
  ///```
  static logBloc(dynamic currentState, dynamic nextState, BlocEvent event) {
    DateTime time = DateTime.now();
    _logBase(
      [
        {
          'preState': currentState,
          'nextState': nextState,
          'event': event.toJson(),
          'time': time.toString(),
        }
      ],
      LogType.bloc,
    );
  }

  static errorDataToModel(String type, dynamic error, dynamic data) {
    groupCollapsed(
      '%c${type}_data_to_model-->catch',
      'color: red; font-weight: bold',
    );
    log('error', error);
    log('item', data);
    groupEnd();
  }
}
