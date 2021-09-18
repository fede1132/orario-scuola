
class ScraperAlgorithm {
  static const List months = ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre"];
  scan(List arr) {
    var now = DateTime.now();
    var month = months[now.month-1];
    var day = now.day;
    var isSunday = now.weekday==7;
    RegExp regex = new RegExp(r"[0-9]+");
    for (var i=0;i<arr.length;i++) {
      String text = arr[i];
      if (text.contains("sospeso")) continue;
      if (text.contains("definitivo")) return i;
      List nums = regex.allMatches(text).map((m)=>int.parse(m[0].toString())).where((m) => m>0&&m<31).toList();
      if (nums.length==0) continue;
      else if (nums.length>=1) {
        if (nums.length == 1 && (nums[0] >= day || (isSunday && nums[0] >= day-1))) {
          return i;
        } else if (nums.length == 2 && (nums[0] >= day || (isSunday && nums[0] >= day-1)) && (nums[1] <= day)) {
          return i;
        } else {
          continue;
        }
      }
    }
    return -1;
  }

}
