/// Created by nghinv on Tue Jun 07 2022

library logger_console;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'bloc_event.dart';

enum LogType {
  info,
  group,
  groupCollapsed,
  groupEnd,
}

class LogConfig {
  final LogType? type;
  final String? color;
  final String? fontWeight;
  final int? fontSize;

  LogConfig({
    this.type = LogType.info,
    this.color,
    this.fontWeight,
    this.fontSize,
  });
}

class Console {
  static WebSocketChannel? _channel;

  /// host socket
  static String host = "localhost";

  /// port socket
  static int port = 9090;

  /// enable [Console.log()]
  ///
  /// default = true when run in debug mode
  /// default = false when run in release mode
  static bool enableLog = kDebugMode ? true : false;

  /// when uri != null, use uri to connect socket
  static String? uri;

  static Map<String, dynamic>? clientInfo;

  static WebSocketChannel? getInstance() {
    if (_channel == null) {
      connectServer();
    }

    return _channel;
  }

  static Uri getUri() {
    String uriString = "ws://$host:$port";
    if (uri != null) {
      uriString = uri!;
    }

    return Uri.parse(uriString);
  }

  /// Get device info
  static Future getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final deviceInfoData = deviceInfo.toMap();

    if (kIsWeb) {
      clientInfo = {
        'name': 'Web',
        'model': 'Web',
        'systemName': 'Web',
        'isPhysicalDevice': 'Unknow',
        'id': deviceInfoData['vendor'] +
            deviceInfoData['userAgent'] +
            deviceInfoData['hardwareConcurrency'].toString(),
      };
    } else if (Platform.isAndroid) {
      clientInfo = {
        'name': deviceInfoData['model'],
        'model': deviceInfoData['model'],
        'systemName': 'Android',
        'isPhysicalDevice': deviceInfoData['isPhysicalDevice'],
        'id': deviceInfoData['androidId'],
      };
    } else if (Platform.isIOS) {
      clientInfo = {
        'name': deviceInfoData['name'],
        'model': deviceInfoData['model'],
        'systemName': deviceInfoData['systemName'],
        'isPhysicalDevice': deviceInfoData['isPhysicalDevice'],
        'id': deviceInfoData['identifierForVendor'],
      };
    } else if (Platform.isLinux) {
      clientInfo = {
        'name': 'Linux',
        'model': 'Linux',
        'systemName': 'Linux',
        'isPhysicalDevice': 'Unknow',
        'id': deviceInfoData['machineId'],
      };
    } else if (Platform.isWindows) {
      clientInfo = {
        'name': 'Window',
        'model': 'Window',
        'systemName': 'Window',
        'isPhysicalDevice': 'Unknow',
        'id': deviceInfoData['machineId'],
      };
    } else if (Platform.isMacOS) {
      clientInfo = {
        'name': 'MacOS',
        'model': 'MacOS',
        'systemName': 'MacOS',
        'isPhysicalDevice': 'Unknow',
        'id': deviceInfoData['machineId'],
      };
    } else {
      clientInfo = {
        'name': 'Unknow',
        'model': 'Unknow',
        'systemName': 'Unknow',
        'isPhysicalDevice': 'Unknow',
        'id': 'Unknow',
      };
    }
  }

  static connectServer([String? data]) async {
    _channel = WebSocketChannel.connect(getUri());
    if (clientInfo == null) {
      await getDeviceInfo();
    }

    final Map<String, dynamic> dataSending = {
      'type': 'fromApp',
      'clientInfo': clientInfo,
    };
    _channel!.sink.add(json.encode(dataSending));

    if (data != null) {
      _channel!.sink.add(data);
    }
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
  static log(dynamic param, [dynamic params, LogConfig? logConfig]) {
    if (enableLog == false) {
      return;
    }

    var jsonParam = param;
    var jsonParams = params;
    try {
      json.encode(param);
    } catch (error) {
      jsonParam = "$param";
    }
    try {
      json.encode(params);
    } catch (error) {
      jsonParams = "$params";
    }

    final Map<String, dynamic> dataSending = {
      'type': 'fromApp',
      'config': {
        'type': logConfig?.type?.name ?? LogType.info.name,
        'color': logConfig?.color,
        'fontWeight': logConfig?.fontWeight,
        'fontSize': logConfig?.fontSize,
      },
      'data': {'param': jsonParam, 'params': jsonParams}
    };

    if (_channel == null) {
      connectServer(json.encode(dataSending));
      return;
    }

    if (_channel!.closeCode != null) {
      _channel = null;
      connectServer(json.encode(dataSending));
      return;
    }

    _channel!.sink.add(json.encode(dataSending));
  }

  static group(dynamic message, [LogConfig? params]) {
    log(message, null, params ?? LogConfig(type: LogType.group));
  }

  static groupCollapsed(dynamic message, [LogConfig? params]) {
    log(message, null, params ?? LogConfig(type: LogType.groupCollapsed));
  }

  static groupEnd() {
    log(null, null, LogConfig(type: LogType.groupEnd));
  }

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
    log({
      'type': 'bloc',
      'data': {
        'preState': currentState,
        'nextState': nextState,
        'event': event.toJson(),
        'time': time.toString(),
      },
    });
  }
}
