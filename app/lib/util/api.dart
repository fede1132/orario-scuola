import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orario_scuola/util/internet.dart';

class API {
  static const String url = "http://localhost:8080/";
  static final API inst = API();
  bool? _sendAnonData = false;
  String? _anonData;

  // fetch token
  Future<APIResponse> getToken(String email) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_sendAnonData == null) {
      var box = await Hive.openBox("settings");
      _sendAnonData = box.get("send_anon_data");
    }
    if (_sendAnonData! && _anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var request = await http.post(Uri.parse("${url}agree-tos/agree-tos?email=$email&agree=true"), body: _sendAnonData! ? _anonData : "");
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
  }

  Future<APIResponse> getSchedule() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_sendAnonData == null) {
      var box = await Hive.openBox("settings");
      _sendAnonData = box.get("send_anon_data");
    }
    if (_sendAnonData! && _anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.post(Uri.parse("${url}schedule/getSchedule/0/1A?token=$token"));
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
  }

  Future<String> genAnonDataBody() async {
    var version;
    var model;
    var manufacter;
    if (Platform.isIOS) {
      var info = await DeviceInfoPlugin().iosInfo;
      version = info.systemVersion;
      model = info.model;
    }
    if (Platform.isAndroid) {
      var info = await DeviceInfoPlugin().androidInfo;
      version = info.version.release;
      model = info.model;
      manufacter = info.manufacturer;
    }
    Map data = {
      version: version,
      model: model,
      manufacter: manufacter
    };
    return json.encode(data);
  }
}

class APIResponse {
  const APIResponse({required this.success, this.code, this.value});
  final bool success;
  final String? code;
  final dynamic value;
}
