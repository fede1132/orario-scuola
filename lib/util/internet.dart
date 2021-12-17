
import 'dart:io';

Future<bool> checkInternetConnection() async {
  try {
    final response = await InternetAddress.lookup("google.com");
    if (response.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } on SocketException {
    return false;
  }
}
