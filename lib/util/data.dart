class Data {
    int _index = -1;
    final List<String> _array;
    
    Data(this._array);

    String skip(int val) {
      _index += val;
      return _array[_index];
    }

    String currentLine() {
      if (_index < 0 || _index >= _array.length) return "";
      return _array[_index];
    }

    String nextLine({bool moveCursor = true}) {
      if (_index+1 == _array.length) return "";
      return _array[moveCursor ? ++_index : _index+1];
    }

    String previousLine() {
      if (_index-1 < 0) return "";
      return _array[--_index];
    }
}
