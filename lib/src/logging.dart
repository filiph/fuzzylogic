part of fuzzylogic;

final Logger logger = new Logger('fuzzylogic');

String _nameOrUnnamed(String name, String type) {
  if (name == null) {
    return "unnamed $type";
  }
  return "$type $name";
}
