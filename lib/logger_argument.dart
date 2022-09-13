part of 'logger_console.dart';

typedef OnCall = void Function(List<dynamic> arguments);

class VarArgsFunction {
  final OnCall callback;

  VarArgsFunction(this.callback);

  void call() => callback([]);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return callback(
      invocation.positionalArguments.map(
        (argument) {
          try {
            return json.encode(argument);
          } catch (e) {
            return "$argument";
          }
        },
      ).toList(),
    );
  }
}