import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orario_scuola/util/internet.dart';

class API {
  static const String url = "https://api.fede1132.me/school/";
  static final API inst = API();
  bool? _sendAnonData = false;
  String? _anonData;

  // fetch token
  Future<APIResponse> getToken(String email, {String? code}) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_anonData == null) {
      _anonData = await genAnonDataBody();
    }
    if (code != null) {
      var request = await http.post(Uri.parse("${url}token/getToken?email=$email&code=$code"), body: _anonData);
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
    }
    var request = await http.post(Uri.parse("${url}agree-tos/agree-tos?email=$email&agree=true"), body: _anonData);
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
  }

  // get desidered schedule
  Future<APIResponse> getSchedule(String? type, String? value) async {
    String? type;
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var box = await Hive.openBox("settings");
    if (type == null || value == null) {
      type = box.get("select_type");
      value = box.get("select_value");
    }
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.post(Uri.parse("${url}schedule/getSchedule/$type/$value?token=$token"), body: _anonData);
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
  }

  // get classes, teachers and rooms data
  Future<APIResponse> getValues() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.post(Uri.parse("${url}schedule/getValues?token=$token"), body: _anonData);
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
  }

  // get url
  Future<APIResponse> getUrl() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.post(Uri.parse("${url}schedule/getUrl?token=$token"), body: _anonData);
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["url"], code: response?["code"]);
  }

  // get url
  Future<APIResponse> updateUrl(String url) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (_anonData == null) {
      _anonData = await genAnonDataBody();
    }
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.post(Uri.parse("${API.url}schedule/updateUrl?token=$token&url=$url"), body: _anonData);
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], code: response?["code"]);
  }

  // decide to send or not anon data to the remote server
  Future<String> genAnonDataBody() async {
    if (_sendAnonData == null) {
      var box = await Hive.openBox("settings");
      _sendAnonData = box.get("send_anon_data");
    }
    if (_sendAnonData! && _anonData == null) {
      _anonData = await genAnonDataBody();
    }
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
    var data = {
      version: version,
      model: model,
      manufacter: manufacter
    };
    return "";
  }
}

class APIResponse {
  const APIResponse({required this.success, this.code, this.value});
  final bool success;
  final String? code;
  final dynamic value;
}
