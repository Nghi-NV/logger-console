import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger_console/logger_console.dart';

void main() async {
  // ensure binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  test('adds one to input values', () {
    Console.enableLog = true;
    Console.log("Hello World");

    sleep(const Duration(seconds: 3));
  });
}
