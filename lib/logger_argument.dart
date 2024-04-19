part of 'logger_console.dart';

typedef _OnCall = void Function(List<dynamic> arguments);

class _VarArgsFunction {
  final _OnCall callback;

  _VarArgsFunction(this.callback);

  void call() => callback([]);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!Console.enableLog) return;

    return callback(
      invocation.positionalArguments.map(
        (argument) {
          try {
            if (argument is StackTrace) {
              if (Console.logTrace) {
                _LogTrace trace = _LogTrace(argument);
                return trace.toString();
              }

              return '';
            }

            return json.encode(argument);
          } catch (e) {
            return "$argument";
          }
        },
      ).toList(),
    );
  }
}
