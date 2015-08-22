part of fuzzylogic;

/**
 * Fuzzy
 */
class FuzzyVariable<T> {
  List<FuzzySet<T>> sets;

  /**
   * This *must* be called before the variable is worked with.
   */
  void init() {
    sets.forEach((FuzzySet<T> fuzzySet) => fuzzySet.variable = this);
  }

  /**
   * Assigns the variable with a crisp value (that has a degree of membership
   * in various FuzzySets of the variable). This creates a [FuzzyValue] which
   * can then be used to resolve other variables using fuzzy rules.
   */
  FuzzyValue<T> assign(T crispValue) {
    var fuzzyValue = new FuzzyValue<T>(this, crispValue);
    return fuzzyValue;
  }

  /**
   * Creates a blank [FuzzyValue] from this variable. This blank value can be
   * then used as output variable for a [FuzzyRuleBase.resolve] method, 
   * and is filled with degrees of truth according to a fuzzy rules.
   */
  FuzzyValue<T> createOutputPlaceholder() {
    var output = new FuzzyValue<T>(this, null);
    return output;
  }
}
