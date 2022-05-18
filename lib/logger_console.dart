library logger_console;

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Console {
  static WebSocketChannel? _channel;
  static String host = "localhost";
  static int port = 9090;

  static WebSocketChannel? getInstance() {
    if (_channel == null) {
      connectServer();
    }

    return _channel;
  }

  static Uri getUri() {
    final uriString = "ws://$host:$port";
    return Uri.parse(uriString);
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final deviceInfoData = deviceInfo.toMap();

    Map<String, dynamic> clientInfo = {};

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
        'name': deviceInfoData['name'],
        'model': deviceInfoData['model'],
        'systemName': deviceInfoData['systemName'],
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

    return clientInfo;
  }

  static connectServer([String? data]) async {
    _channel = WebSocketChannel.connect(getUri());
    final clientInfo = await getDeviceInfo();

    final Map<String, dynamic> dataSending = {
      'type': 'fromApp',
      'clientInfo': clientInfo,
    };

    _channel!.sink.add(json.encode(dataSending));

    if (data != null) {
      _channel!.sink.add(data);
    }
  }

  static log(dynamic param, [dynamic params]) {
    final Map<String, dynamic> dataSending = {
      'type': 'fromApp',
      'data': {'param': param, 'params': params}
    };

    if (_channel == null) {
      connectServer(json.encode(dataSending));
      return;
    }

    _channel!.sink.add(json.encode(dataSending));
  }
}
