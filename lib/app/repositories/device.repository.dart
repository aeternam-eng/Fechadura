import 'dart:convert';
import 'package:flutter_blue_example/app/models/device.model.dart';
import 'package:http/http.dart' as http;

class DeviceRepository {
  Future<List<Device>> getByLogin(int? clientId) async {
    try {
      http.Response response = await http.get(Uri.parse(
        "https://fechadura.azurewebsites.net/api/v1/Devices?clientId=$clientId"));

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
          .map((x) => Device.fromJson(x))
          .toList();
      }

      throw new Exception(jsonDecode(response.body));
    } catch (e) {
      return List<Device>.empty(growable: true);
    }
  }

  Future<int> createDevice(int? clientId, String nick, String bluetoothId) async {
    try {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['clientId'] = clientId;
      data['nick'] = nick;
      data['bluetoothId'] = bluetoothId;

      http.Response response = await http.post(
        Uri.parse("https://fechadura.azurewebsites.net/api/v1/Devices/"),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"});

      if (response.statusCode == 201) {
        var temp = (jsonDecode(response.body));

        return temp;
      }

      throw new Exception(
        "Erro ao tentar criar o dispositivo. ${jsonDecode(response.body)}");
    } catch (e) {
      return 0;
    }
  }
}
