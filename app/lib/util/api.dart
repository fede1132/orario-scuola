import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orario_scuola/util/internet.dart';

class API {
  static const String url = "http://localhost:8080/";
  static final API inst = API();

  // fetch token
  Future<APIResponse> getToken(String email, {String? code}) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    if (code != null) {
      var request = await http.post(Uri.parse("${url}account/login?email=$email&code=$code"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
    }
    var request = await http.post(Uri.parse("${url}account/login?email=$email&agree=true"));
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
  }

  // get desidered schedule
  Future<APIResponse> getSchedule(String? type, String? value) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    var box = await Hive.openBox("settings");
    if (type == null) {
      type = box.get("select_type");
    }
    if (value == null) {
      value = box.get("select_value");
    }
    var token = (await Hive.openBox("settings")).get("token");
    try {
      var request = await http.post(Uri.parse("${url}schedule/getSchedule/$type/$value?token=$token"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
    } catch (ex) {
      return APIResponse(success: false, code: "remote.error");
    }
  }

  // get classes, teachers and rooms data
  Future<APIResponse> getValues() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    var token = (await Hive.openBox("settings")).get("token");
    try {
      var request = await http.post(Uri.parse("${url}schedule/getValues?token=$token"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
    } catch (ex) {
      return APIResponse(success: false, code: "remote.error");
    }
  }

  // get url
  Future<APIResponse> getUrl() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    var token = (await Hive.openBox("settings")).get("token");
    try {
      var request = await http.post(Uri.parse("${url}schedule/getUrl?token=$token"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], value: response?["url"], code: response?["code"]);
    } catch (ex) {
      return APIResponse(success: false, code: "remote.error");
    }
  }

  // update url
  Future<APIResponse> updateUrl(String url) async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    var token = (await Hive.openBox("settings")).get("token");
    try {
      var request = await http.post(Uri.parse("${API.url}schedule/update?token=$token&url=$url"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], code: response?["code"]);
    } catch (ex) {
      return APIResponse(success: false, code: "remote.error");
    }
  }

  // update
  Future<APIResponse> update() async {
    if (!(await checkInternetConnection())) {
      return APIResponse(success: false, code: "internet.not-connected");
    }
    var token = (await Hive.openBox("settings")).get("token");
    try {
      var request = await http.post(Uri.parse("${API.url}schedule/update?token=$token"));
      var response = json.decode(request.body);
      return APIResponse(success: response["success"], code: response?["code"], value: response?["time"]);
    } catch (ex) {
      return APIResponse(success: false, code: "remote.error");
    }
  }
}

class APIResponse {
  const APIResponse({required this.success, this.code, this.value});
  final bool success;
  final String? code;
  final dynamic value;
}
