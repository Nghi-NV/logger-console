library logger_console;

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  static bool logEnable = kDebugMode ? true : false;

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

    _channel!.stream.listen((onData) {}, onDone: () {
      _channel = null;
    });
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
  static log(dynamic param, [dynamic params]) {
    if (logEnable == false) {
      return;
    }

    final Map<String, dynamic> dataSending = {
      'type': 'fromApp',
      'data': {'param': param, 'params': params}
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
}
