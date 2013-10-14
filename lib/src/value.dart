part of fuzzylogic;

/**
 * FuzzyValue is a FuzzyVariable that was initialized with a value (normally
 * by calling [FuzzyVariable.assign()] just before resolving the [RuleBase]).
 */
class FuzzyValue<T> {
  FuzzyValue(this.variable, [T crispValue]) {
    assert(variable != null);
    degreesOfTruth = new Map<FuzzySet<T>, num>();
    variable.sets.forEach((set) => degreesOfTruth[set] = 0.0);
    
    if (crispValue != null) {
      this.crispValue = crispValue;
    }
  }
  
  FuzzyVariable<T> variable;
  Map<FuzzySet<T>, num> degreesOfTruth; // TODO get - throw if unitialized
  T _crispValue; // TODO get, set
  num _crispValueConfidence;
  
  T get crispValue {
    if (_crispValue != null) {
      return _crispValue;
    } else {
      _computeCrispValue();
      return _crispValue;
    }
  }
  
  num get confidence {
    // TODO
    return _crispValueConfidence;
  }
  
  set crispValue(T value) {
    _crispValue = value;
    _crispValueConfidence = 1.0;
    _setDegreesOfTruthFromCrispValue();
  }
  
  /**
   * Sets degrees of truth of a variable which has been assigned a crisp value.
   */
  void _setDegreesOfTruthFromCrispValue() {
    variable.sets.forEach((set) => 
        set.setDegreeOfTruth(set.getDegreeOfMembership(_crispValue), [this]));
  }
  
  /**
   * Compute the crisp value using the Average of Maxima method.
   */
  void _computeCrispValue() {
    assert(T == num || T == int);  // Average of Maxima only works on numeric crisp values.
    num numerator = variable.sets.fold(0, (sum, fuzzySet) => 
        sum + (fuzzySet.representativeValue as num) * degreesOfTruth[fuzzySet]);
    num denominator = degreesOfTruth.values.fold(0, (sum, dot) => sum + dot);
    if (denominator == 0) {
      // No confidence.
      _crispValue = null;
    } else if (T == int) {
      _crispValue = numerator ~/ denominator;
    } else if (T == num) {
      _crispValue = numerator / denominator;
    } else {
      _crispValue = numerator / denominator;
      // TODO: the (T == num) doesn't work in dart2js 
      // uncomment below and delete above
      //throw new StateError("Cannot compute AvMax for non-numeric values.");
    }
    _crispValueConfidence = degreesOfTruth.values.reduce(max);
  }
  
  /**
   * Sets the degree of truth for a [FuzzySet] which is a part of this 
   * [FuzzyValue].
   */
  void setDegreeOfTruth(FuzzySet<T> set, num degreeOfTruth) {
    assert(variable.sets.contains(set));
    var currentDegreeOfTruth = degreesOfTruth[set];
    if (currentDegreeOfTruth == null) { 
      degreesOfTruth[set] = degreeOfTruth;
    } else if (currentDegreeOfTruth < degreeOfTruth) {
      degreesOfTruth[set] = degreeOfTruth;
    }
  }
}
