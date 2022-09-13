import 'package:flutter/material.dart';
import 'package:logger_console/logger_console.dart';
import 'test_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  void onLogPress() {
    Console.log("%c Hello World", "color: red; font-size: 20px");
    Console.log("%cTodoList", 'color: green; font-weight: bold;', todos);
  }

  void onLogInfoPress() {
    Console.info("%cLog Info::", 'color: green; font-weight: bold;', todos);
  }

  void onLogWarnPress() {
    Console.warn("Not Found");
  }

  void onLogErrorPress() {
    Console.error("Server Error");
  }

  void onLogGroupPress() {
    Console.group("TodoList");
    Console.log("todos", todos);
    Console.count("count call");
    Console.groupEnd();
  }

  void onLogGroupCollapsedPress() {
    Console.groupCollapsed("%cTodoList:::", "color: green; font-weight: bold");
    Console.log("todos", todos);
    Console.count("count call");
    Console.groupEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: onLogPress,
              child: const Text("Console.log"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogInfoPress,
              child: const Text("Console.info"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogWarnPress,
              child: const Text("Console.warn"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogErrorPress,
              child: const Text("Console.error"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogGroupPress,
              child: const Text("Console.group"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogGroupCollapsedPress,
              child: const Text("Console.groupCollapsed"),
            ),
          ],
        ),
      ),
    );
  }
}
