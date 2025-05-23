import 'dart:async';
import 'package:flutter/services.dart';

enum AudioPort {
  /// unknow 0
  unknow,

  /// input 1
  receiver,

  /// out speaker 2
  speaker,

  /// headset 3
  headphones,

  /// bluetooth 4
  bluetooth,
}

class AudioInput {
  final String name;
  final int _port;
  AudioPort get port {
    return AudioPort.values[_port];
  }

  const AudioInput(this.name, this._port);

  @override
  String toString() {
    return "name:$name,port:$port";
  }
}

class FlutterAudioManager {
  static const MethodChannel _channel =
      const MethodChannel('flutter_audio_manager');
  static void Function()? _onInputChanged;

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<AudioInput> getCurrentOutput() async {
    final List<dynamic> data = await _channel.invokeMethod('getCurrentOutput');
    return AudioInput(data[0], int.parse(data[1]));
  }

  Future<List<AudioInput>> getAvailableInputs() async {
    final List<dynamic> list =
        await _channel.invokeMethod('getAvailableInputs');

    List<AudioInput> arr = [];
    list.forEach((data) {
      arr.add(AudioInput(data[0], int.parse(data[1])));
    });
    return arr;
  }

  Future<bool> changeToSpeaker() async {
    return await _channel.invokeMethod('changeToSpeaker');
  }

  Future<bool> changeToReceiver() async {
    return await _channel.invokeMethod('changeToReceiver');
  }

  Future<bool> changeToHeadphones() async {
    return await _channel.invokeMethod('changeToHeadphones');
  }

  Future<bool> changeToBluetooth() async {
    return await _channel.invokeMethod('changeToBluetooth');
  }

  void setListener(void Function() onInputChanged) {
    FlutterAudioManager._onInputChanged = onInputChanged;
    _channel.setMethodCallHandler(_methodHandle);
  }

  Future<void> _methodHandle(MethodCall call) async {
    if (_onInputChanged == null) return;
    switch (call.method) {
      case "inputChanged":
        return _onInputChanged!();
      default:
        break;
    }
  }
}
