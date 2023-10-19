class SBV implements StringSink{
  //STRING Buffer that compares by value instead of reference
  late final StringBuffer buffer;
  SBV(String s){
    buffer=StringBuffer(s);
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SBV && other.buffer.toString() == buffer.toString();
  }
  @override
  String toString() {
    // TODO: implement toString
    return buffer.toString();
  }
  void clear(){
    buffer.clear();
  }void rewrite(String s){
    clear();
    buffer.write(s);
  }
  @override
  int get hashCode => buffer.toString().hashCode;

  @override
  void write(Object? object) {
    // TODO: implement write
    buffer.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    // TODO: implement writeAll
    buffer.writeAll(objects,separator);
  }

  @override
  void writeCharCode(int charCode) {
    // TODO: implement writeCharCode
    buffer.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    // TODO: implement writeln
    buffer.writeln(object);
  }
}