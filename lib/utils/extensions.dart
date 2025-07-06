extension ContainsAny on String {
  bool containsAny(Iterable<String> values) {
    return values.any(contains);
  }
}