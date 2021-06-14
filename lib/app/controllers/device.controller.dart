import 'package:flutter_blue_example/app/models/device.model.dart';
import 'package:flutter_blue_example/app/repositories/device.repository.dart';

class DeviceController {
  List<Device> list = [];
  DeviceRepository repository = DeviceRepository();

  Future<void> getByLogin(int? id) async {
    try {
      final allList = await repository.getByLogin(id);

      list = allList;
    } catch (e) {
      print("Erro: " + e.toString());
    }
  }

  Future<void> create(String nick, int? clientId, String bluetoothId) async {
    try {
      final deviceId = await repository.createDevice(clientId, nick, bluetoothId);

      Device device = Device(
        idDevice: deviceId,
        nome: nick,
        criadoEm: DateTime.now(),
        bluetoothId: bluetoothId);

      list.add(device);
    } catch (e) {
      print("Erro: " + e.toString());
    }
  }
}
