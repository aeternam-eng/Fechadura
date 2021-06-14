import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/app/models/device.model.dart';

Guid serviceId = Guid('9e98d7aF-d2f9-42f5-acd2-bcb5a5cdc7df');

class DevicePanelItem {
  String headerValue;
  bool isExpanded;
  Device item;

  DevicePanelItem(
      {required this.headerValue, this.isExpanded = false, required this.item});
}


class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  Future<void> _sendOpenLock(List<BluetoothService> services) async {
    for (var s in services) {
      if (s.uuid == serviceId) {
        for (var c in s.characteristics) {
          var value = await c.read();
          if (value[0] == 0xFF) {
            await c.write([0x7f], withoutResponse: true);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }

              return TextButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button!
                      .copyWith(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                return ListTile(
                  leading: (snapshot.data == BluetoothDeviceState.connected)
                      ? Icon(Icons.bluetooth_connected)
                      : Icon(Icons.bluetooth_disabled),
                  title: Text(
                      'Device is ${snapshot.data.toString().split('.')[1]}.'),
                  subtitle: Text('${device.id}'),
                );
              },
            ),
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                if (snapshot.data! == BluetoothDeviceState.connected) {
                  device.discoverServices();
                  return StreamBuilder<bool>(
                    stream: device.isDiscoveringServices,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data! == false) {
                        return StreamBuilder<List<BluetoothService>>(
                          stream: device.services,
                          initialData: [],
                          builder: (c, snapshot) {
                            if (snapshot.hasData) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20),
                                  onSurface: Colors.blue,
                                ),
                                onPressed: () {
                                  _sendOpenLock(snapshot.data!);
                                },
                                child: const Text("Open Lock"),
                              );
                            } else {
                              return SizedBox(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.grey),
                                ),
                                width: 18.0,
                                height: 18.0,
                              );
                            }
                          },
                        );
                      }
                      return SizedBox(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.grey),
                        ),
                        width: 18.0,
                        height: 18.0,
                      );
                    },
                  );
                }
                return SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.grey),
                  ),
                  width: 18.0,
                  height: 18.0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
