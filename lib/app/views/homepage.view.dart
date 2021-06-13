import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/app/controllers/client.controller.dart';
import 'package:flutter_blue_example/app/controllers/device.controller.dart';
import 'package:flutter_blue_example/app/models/client.model.dart';
import 'package:flutter_blue_example/app/models/device.model.dart';
import 'package:flutter_blue_example/app/views/cadastroDispositivo.view.dart';
import 'package:flutter_blue_example/app/views/deviceScreen.view.dart';
import 'package:flutter_blue_example/app/widgets/scan_result_tile.widget.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  Client _cliente = Client();
  List<Device> _listaDispositivo = [];
  HomePage(this._cliente, this._listaDispositivo);
  @override
  _HomePageState createState() => _HomePageState(_cliente, _listaDispositivo);
}

class DevicePanelItem {
  String headerValue;
  bool isExpanded;
  Device item;

  DevicePanelItem(
      {required this.headerValue, this.isExpanded = false, required this.item});
}

class _HomePageState extends State<HomePage> {
  final ble = FlutterBlue.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textDeviceController = TextEditingController();
  ClientController _clientController = ClientController();
  DeviceController _deviceController = DeviceController();
  DateTime selectedDate = DateTime.now();
  Client _cliente = Client();
  List<Device> _listaDispositivo = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<DevicePanelItem> list_panel = [];

  _HomePageState(this._cliente, this._listaDispositivo);

  @override
  void initState() {
    super.initState();

    /*SharedPreferences.getInstance().then((value) {
      final _firstTime = value.getBool('firstTime') ?? true;
      if (_firstTime) {
        _displayFirstDialog(context);
        value.setBool('firstTime', false);
      }
    });

    setState(() {
      list_panel = generateDevicePanelItem();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        title: Text(
          'Dispositivos',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(Duration(seconds: 2))
                      .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) {
                    List<BluetoothDevice> devices = snapshot.data!;
                    return Column(
                      children: devices.map((d) {
                        // d.connect();
                        // d.discoverServices();
                        return StreamBuilder<List<BluetoothService>>(
                            stream: d.services,
                            builder: (c, snapshot) {
                              if (snapshot.hasData) {
                                for (BluetoothService service
                                    in snapshot.data!) {
                                  if (service.uuid ==
                                      Guid(
                                          '9e98d7aF-d2f9-42f5-acd2-bcb5a5cdc7df')) {
                                    return ListTile(
                                      title: Text(d.name),
                                      subtitle: Text(d.id.toString()),
                                      trailing: StreamBuilder<
                                              BluetoothDeviceState>(
                                          stream: d.state,
                                          initialData:
                                              BluetoothDeviceState.disconnected,
                                          builder: (c, snapshot) {
                                            if (snapshot.data ==
                                                BluetoothDeviceState
                                                    .connected) {
                                              return ElevatedButton(
                                                child: Text('VIEW'),
                                                onPressed: () =>
                                                    Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DeviceScreen(device: d),
                                                  ),
                                                ),
                                              );
                                            }
                                            return Text(
                                                snapshot.data.toString());
                                          }),
                                    );
                                  }
                                }
                              }
                              return Text('');
                            });
                      }).toList(),
                    );
                  }),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                r.device.connect();
                                return DeviceScreen(device: r.device);
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () => FlutterBlue.instance.startScan(
                //withServices: [Guid('9e98d7aF-d2f9-42f5-acd2-bcb5a5cdc7df')],
                timeout: Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  /*floatingActionButton: FloatingActionButton(
          onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CadastroDispositivo(_cliente, _listaDispositivo)))
              .whenComplete(
            () => {
              _deviceController.getByLogin(_cliente.idClient).then(
                    (value) => setState(
                      () {
                        _listaDispositivo = _deviceController.list;
                        list_panel = generateDevicePanelItem();
                      },
                    ),
                  ),
            },
          );
        },
        child: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.purple,
          ),*/

  /*List<DevicePanelItem> generateDevicePanelItem() {
    return List.generate(
      _listaDispositivo.length,
      (index) => DevicePanelItem(
          headerValue: _listaDispositivo[index].nome,
          isExpanded: false,
          item: _listaDispositivo[index]),
    );
  }

  Widget _buildDevicePanel(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          list_panel[index].isExpanded = !isExpanded;
        });
      },
      children:
          list_panel.map<ExpansionPanel>((DevicePanelItem devicePanelItem) {
        return ExpansionPanel(
          backgroundColor: Colors.black,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(devicePanelItem.headerValue),
            );
          },
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buttonConnect(),
                _buttonSwitch(),
              ],
            ),
          ),
          isExpanded: devicePanelItem.isExpanded,
        );
      }).toList(),
    );
  }

  Widget _buttonConnect() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        onSurface: Colors.blue,
      ),
      onPressed: null,
      child: const Text("Conectar"),
    );
  }

  Widget _buttonSwitch() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        onSurface: Colors.green[200],
      ),
      onPressed: null,
      child: const Text("Abrir"),
    );
  }

  _displayFirstDialog(context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              "Seja bem vindo! Parece que esta é a primeira vez que você" +
                  "abre este aplicativo! Através dele, você pode facilmente" +
                  " monitorar e visualizar seus dispositivos!"),
          actions: <Widget>[
            TextButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/
}
