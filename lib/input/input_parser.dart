/// MIght be subjected to change: rename refactor to different files:
library;

/// Controlling class (?)
class InputParser{
  List<List<dynamic>> loadedData = [];

  /// Parses one line of data and returns the result
  Answer parseLine(List<dynamic> line){
    return Answer();
  }
  /// Check errors from betwwen lines

}
/// Holds result and stats of entire parsing process
/// Works regardless of shape
class InputResult{
  List<Answer> answers = [];

}
/// holds one line of processed data, with its outcome
class Answer{

}

enum ParseStatus{ ok, format, warn, bad, empty }
extension ParseStatusCmp on ParseStatus {
  int compareTo(ParseStatus other) =>index.compareTo(other.index);
  bool operator <(ParseStatus other) => index < other.index;
  bool operator >(ParseStatus other) => index > other.index;
  bool operator <=(ParseStatus other) => index <= other.index;
  bool operator >=(ParseStatus other) => index >= other.index;
  //bool operator ==(ParseStatus other) => index == other.index; // cannot be overridden
  //bool operator !=(ParseStatus other) => index != other.index;
}