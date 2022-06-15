part of 'logger_console.dart';

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
