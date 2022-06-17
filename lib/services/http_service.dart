import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pasaporte/views/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mqtt_service.dart';

class HttpService {

  static final globalPath = 'http://34.94.79.113:9090/api/';
  MqttService mqtt = MqttService();

  Future<String> uploadPhotos(List<String> paths) async {
    Uri uri = Uri.parse('${globalPath}documents/identification/upload');

    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    for(String path in paths){
      request.files.add(await http.MultipartFile.fromPath('file', path));
    }

    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);

    var json = jsonDecode(responseString);
    var file = json["url"];
    var arrayFile = file.split("/");
    print(arrayFile[5]);

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? registrationTag = sharedPreferences.getString("registration_tag");
    print(registrationTag);

    if(json["message"] == "File saved"){
      mqtt.connect(registrationTag!, arrayFile[5]);
      await EasyLoading.showSuccess(
          "Se ha enviado la imagen con éxito");
    } else {
      await EasyLoading.showError(
          "Solo se aceptan imágenes jpg, png y jpeg");
    }

    return responseString;
  }

  static Future<http.Response> login(user, password, context) async {

    String bodyEmail = jsonEncode(<String, String>{
      'email': user,
      'password': password
    });

    String bodyRegistrationTag = jsonEncode(<String, String>{
      'registration_tag': user,
      'password': password
    });

    String body = user.toString().contains("@") ? bodyEmail : bodyRegistrationTag;

    final response = await http.post(
      Uri.parse('${globalPath}mode/admin/login/token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body
    );

    if(response.statusCode == 404 || response.statusCode == 401){
      await EasyLoading.showError(
          "Sus credenciales son incorrectas, vuelva a intentarlo");
    }

    var json = jsonDecode(response.body);
    var jsonUser = json['user'];

    if (response.statusCode == 200) {
      if (json['message'] == 'Access success') {
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString("token", json['token']);
        sharedPreferences.setString("registration_tag", jsonUser['registration_tag']);

        await EasyLoading.showSuccess("Ingreso exitoso");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
              (Route<dynamic> route) => false,
        );
      } else {
        EasyLoading.showError(json['message']);
      }
      return jsonDecode(response.body);
    } else {
      await EasyLoading.showError(
          "Se ha producido un error interno, vuelva a intentarlo más tarde");

      return jsonDecode(response.body);
    }
  }

}