part of 'logger_console.dart';

class ClientInfo {
  final String id;
  final String name;
  final String platform;
  final bool debug;
  final bool? isSimulator;
  final String? version;
  final String? buildVersion;
  final String? model;
  final String? manufacturer;
  final String? os;
  final String? osVersion;
  final String? language;
  final String? timeZone;
  final String? userAgent;
  final double? screenWidth;
  final double? screenHeight;
  final double? screenScale;
  final double? windowWidth;
  final double? windowHeight;
  final double? windowScale;
  final bool? isPortrait;
  final bool? isLandscape;
  final bool? isDarkMode;

  ClientInfo({
    required this.id,
    required this.name,
    required this.platform,
    this.debug = kDebugMode,
    this.isSimulator,
    this.version,
    this.buildVersion,
    this.model,
    this.manufacturer,
    this.os,
    this.osVersion,
    this.language,
    this.timeZone,
    this.userAgent,
    this.screenWidth,
    this.screenHeight,
    this.screenScale,
    this.windowWidth,
    this.windowHeight,
    this.windowScale,
    this.isPortrait,
    this.isLandscape,
    this.isDarkMode,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "platform": platform,
      "debug": debug,
      "simulator": isSimulator,
      "version": version,
      "buildVersion": buildVersion,
      "model": model,
      "manufacturer": manufacturer,
      "os": os,
      "osVersion": osVersion,
      "language": language,
      "timeZone": timeZone,
      "userAgent": userAgent,
      "screenWidth": screenWidth,
      "screenHeight": screenHeight,
      "screenScale": screenScale,
      "windowWidth": windowWidth,
      "windowHeight": windowHeight,
      "windowScale": windowScale,
      "isPortrait": isPortrait,
      "isLandscape": isLandscape,
      "isDarkMode": isDarkMode,
    };
  }
}

enum LogType {
  clear,
  log,
  count,
  countReset,
  error,
  info,
  warn,
  group,
  groupCollapsed,
  groupEnd,
  bloc,
}

class BlocEvent {
  final String? type;
  final dynamic payload;

  BlocEvent({this.type, this.payload});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
    };
  }
}

class _RequestData {
  final int timestamp;
  final LogType logType;
  final bool secure;
  final _PayloadData payload;

  _RequestData({
    required this.timestamp,
    required this.logType,
    required this.secure,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp,
      "logType": logType.name,
      "secure": secure,
      "payload": payload.toJson(),
      "language": "flutter",
    };
  }
}

class _PayloadData {
  final String data;
  final String? encryptionKey;

  _PayloadData({
    required this.data,
    this.encryptionKey,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dataJson = {
      "data": data,
    };

    if (encryptionKey != null) {
      dataJson["encryptionKey"] = encryptionKey;
    }

    return dataJson;
  }
}
