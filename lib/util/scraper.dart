import 'dart:convert';
import 'data.dart';

Object scrapeValues(String html) {
  var data = new Data(new LineSplitter().convert(html.replaceAll("&nbsp;", "").replaceAll(r'/^\s*\n/gm', "")));
  var line = data.nextLine();
  var values = {};
  while (true) {
    if (line.startsWith("<TD")) {
      var key = values.length;
      values[key] = [];
      line = data.skip(3);
      while (line != "</TD>") {
        line = _cleanString(line);
        if (line.length != 0) values[key].add(line);
        line = data.nextLine();
      }
    }
    if (values.length >= 3) break; 
    line = data.nextLine();
  }
  return values;
}

dynamic scrape(String html) {
  var data = new Data(new LineSplitter().convert(html.replaceAll(RegExp(r'/(&nbsp;)/'), "").replaceAll(RegExp(r'/^\s*\n/gm'), "")));
  // raw data
  List<String> hours = [];
  int defaultColspan = 1;
  var unsorted = {};

  var line = data.nextLine();
  var row = 0;
  // skip the table head
  while (row < 2) {
    line = data.nextLine();
    if (line.startsWith("<TR")) row++;
  }
  row = 0;
  // start the loop
  while (true) {
    line = data.nextLine();
    // tr = new row
    if (line.contains("TR")) {
      if (line.startsWith("<TR")) row++;
      continue;
    }
    // end of the table
    if (line == "</TABLE>") break;
    // skip empty cells
    if (line.startsWith('<TD') && data.nextLine(moveCursor: false) == '</TD>') continue;
    // filter hours (ex. 8.00, 9.00)
    if (line == "<TD class = 'mathema' NOWRAP>") {
      hours.add(data.nextLine());
      data.nextLine();
      continue;
    }

    // rowspan = lessons row
    if (line.contains("ROWSPAN")) {
      // cell settings
      var colspan = int.parse(line.substring(line.indexOf("COLSPAN=")+8, line.indexOf("COLSPAN=")+9));
      if (defaultColspan<colspan) defaultColspan = colspan;
      var rowspan = int.parse(line.substring(line.indexOf("ROWSPAN=")+8, line.indexOf("ROWSPAN=")+9));
      dynamic lesson = {
        "colspan": colspan,
        "rowspan": rowspan,
        "teachers": []
      };
      var name = _cleanString(data.nextLine());
      while (name.contains("&nbsp;")) {
        line = data.nextLine();
        if (line == "</TD>") break;
        name = _cleanString(line);
      }
      var lessonData = [
        name // lesson name
      ];
      if (line != "</TD>") line = data.nextLine();
      // get contents of the cell
      while (line != "</TD>") {
        if (!line.contains("nbsp;")) {
            var cleaned = _cleanString(line);
            if (cleaned.length > 0) lessonData.add(cleaned);
        }
        line = data.nextLine(); // teachers & room
      }
      if (lessonData.length==1) {
          if (unsorted[row] == null) unsorted[row] = [];
          unsorted[row].add({
              "colspan": 1,
              "rowspan": 1,
              "empty": true
          });
          continue;
      }
      // format cell data into an object
      lesson["name"] = lessonData[0];
      for (int i=1;i<lessonData.length-1;i++) {
          lesson["teachers"]?.add(lessonData[i]);
      }
      // if the lesson name contains "VIDEOLEZIONE" there is no room
      if (!lessonData[0].contains("VIDEOLEZIONE")) lesson["room"] = lessonData[lessonData.length-1];
      else lesson["teachers"]?.add(lessonData[lessonData.length-1]);

      // push the result to an array to be sorted
      if (unsorted[row] == null) unsorted[row] = [lesson];
      else unsorted[row].add(lesson);
    }
  }

  // now sort the lessons
  dynamic sorted = {
  };
  // fill the array with empty cells, the numbers of cells will be the result of hours.length * 6 (days of the school week)
  for (int i=0;i<hours.length;i++) {
    var row = [];
    for (int j=0;j<6;j++) {
      row.add([]);
    }
    sorted[hours[i]] = row;
  }
  
  var day = 0;
  // iterate over the hours
  for (int hour=0;hour<hours.length;hour++) {
    day = 0;
    // iterate over the unsorted lessons
    for (var lesson in unsorted[hour]) {
      // scan for the next empty day
      while (sorted[hours[hour]][day].length > 0) {
        day++;
        if (day>5) {
            day = 5;
            break;
        }
      }
      if (lesson["colspan"] < defaultColspan
          && day != 0
          && sorted[hours[hour]][day-1] != null
          && sorted[hours[hour]][day-1][0]["colspan"] != defaultColspan
          && sorted[hours[hour]][day-1].length != defaultColspan) {
          --day;
      }
      for (int i=0;i<lesson["rowspan"];i++) {
          sorted[hours[hour+i]][day].add(lesson);
      }
    }
  }
  return sorted;
}

// clean the content from html tags
String _cleanString(String line) {
    return line.replaceAll(RegExp(r'<[^>]*>'), "").trim();
}

