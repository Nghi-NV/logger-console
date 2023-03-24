part of 'logger_console.dart';

class _LogTrace {
  final StackTrace _trace;

  String? fileName;
  int? lineNumber;
  int? columnNumber;

  _LogTrace(this._trace) {
    _parseTrace();
  }

  void _parseTrace() {
    final traceString = _trace.toString().split("\n")[0];

    /* Search through the string and find the index of the file name by looking for the '.dart' regex */
    final indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z]+.dart'));

    final fileInfo = traceString.substring(indexOfFileName);

    final listOfInfos = fileInfo.split(":");

    fileName = listOfInfos[0];
    lineNumber = int.parse(listOfInfos[1]);
    var columnStr = listOfInfos[2];
    columnStr = columnStr.replaceFirst(")", "");
    columnNumber = int.parse(columnStr);
  }

  @override
  String toString() {
    return "$fileName:$lineNumber:$columnNumber";
  }
}
