import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class API {
  static const String url = "http://localhost:8080/";
  static final API inst = API();

  // fetch token
  Future<APIResponse> getToken(String email) async {
    var request = await http.get(Uri.parse("${url}agree-tos/agree-tos?email=$email&agree=true"));
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["token"], code: response?["code"]);
  }

  Future<APIResponse> getSchedule() async {
    var token = (await Hive.openBox("settings")).get("token");
    var request = await http.get(Uri.parse("${url}schedule/getSchedule/0/2H?token=$token"));
    var response = json.decode(request.body);
    return APIResponse(success: response["success"], value: response?["data"], code: response?["code"]);
  }
}

class APIResponse {
  const APIResponse({required this.success, this.code, this.value});
  final bool success;
  final String? code;
  final dynamic value;
}
