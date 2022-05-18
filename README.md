# Console log package

<p align="center">
<img src='./assets/example.png'>
</p>

## Usage

- Download [`ServerLog`](https://drive.google.com/drive/folders/1h3qreStLaesHTFkgwHRKaMZFrt88Cx-Y?usp=sharing) application for mac os

In the main.dart set `logEnable = true` for release mode 
```dart
Console.logEnable = true;
```

```dart
import 'package:logger_console/logger_console.dart';
  
onShowLog() {
  Console.log("string or object...");

  Console.log([
    {"color": "red", "value": "#f00"},
    {"color": "green", "value": "#0f0"},
    {"color": "blue", "value": "#00f"},
    {"color": "cyan", "value": "#0ff"},
    {"color": "magenta", "value": "#f0f"},
    {"color": "yellow", "value": "#ff0"},
    {"color": "black", "value": "#000"},
  ]);

  Console.log("data", [
    {"color": "red", "value": "#f00"},
    {"color": "green", "value": "#0f0"},
    {"color": "blue", "value": "#00f"},
    {"color": "cyan", "value": "#0ff"},
    {"color": "magenta", "value": "#f0f"},
    {"color": "yellow", "value": "#ff0"},
    {"color": "black", "value": "#000"},
  ]);
}
```

## Additional information

