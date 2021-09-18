import 'dart:io';

class OnlineChecker {
  static Future<bool> isOnline() async {
     try {
       final result = await InternetAddress.lookup('google.com');
       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
         return true;
       }
       return false;
     } on SocketException catch (_) {
       return false;
    }
  }
}