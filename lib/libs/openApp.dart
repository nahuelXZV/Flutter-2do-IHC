import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shake/shake.dart';
// ignore_for_file: depend_on_referenced_packages

final service = FlutterBackgroundService();
final flutterTts = FlutterTts();
ShakeDetector? detector;
int _counter = 0;

Future initializeService() async {
  _initShakeListen();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  _initShakeListen();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      //set as foreground
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      //set as background
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }

    _startListening();

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "counter": _counter,
      },
    );
  });
}

void _initShakeListen() async {
  detector = ShakeDetector.waitForStart(onPhoneShake: speak);
}

void _startListening() async {
  detector?.startListening();
}

void _stopListening() async {
  detector?.stopListening();
}

void speak() {
  flutterTts.speak("Shake detected");
  _counter++;
}
