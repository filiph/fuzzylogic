part of fuzzylogic;

class FuzzyVariable<T> {
  List<FuzzySet> sets;

  void init() {
    sets.forEach((FuzzySet fuzzySet) => fuzzySet.variable = this);
  }
  
  FuzzyValue<T> assign(T crispValue) {
    var fuzzyValue = new FuzzyValue<T>(this, crispValue);
    return fuzzyValue;
  }
  
  FuzzyValue<T> createOutputPlaceholder() {
    var output = new FuzzyValue<T>(this, null);
    return output;
  }
}
