import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/app/views/bluetoothOff.view.dart';
import 'package:flutter_blue_example/app/views/findDevices.view.dart';
import 'package:flutter_blue_example/app/views/login.view.dart';

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state!);
          }),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Fechaduras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.white10,
        primaryColor: Colors.deepPurple,
        primaryColorDark: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: Colors.purple,
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.blue),
      ),
      home: LoginPage(),
    );
  }
}
