import 'package:flutter_background_service/flutter_background_service.dart'
    show FlutterBackgroundService, IosConfiguration, ServiceInstance;
import 'package:flutter/material.dart';
import 'libs/openApp.dart';
import 'principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  _initSeen();
  runApp(const MyApp());
}

_initSeen() async {
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();
  print('isRunning: $isRunning');
  if (isRunning) {
    service.invoke("stopService");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ayudame',
        //  sacar el banner de debug
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Principal());
  }
}
