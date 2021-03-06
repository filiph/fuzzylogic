part of fuzzylogic;

/// FuzzyValue is a FuzzyVariable that was initialized with a value (normally
/// by calling [FuzzyVariable.assign()] just before resolving the [RuleBase]).
class FuzzyValue<T extends num> {
  FuzzyValue(this.variable, [T crispValue]) {
    assert(variable != null);
    degreesOfTruth = <FuzzySet<T>, num>{};
    variable.sets.forEach((set) => degreesOfTruth[set] = 0.0);

    if (crispValue != null) {
      this.crispValue = crispValue;
    }
  }

  FuzzyVariable<T> variable;
  Map<FuzzySet<T>, num> degreesOfTruth; // TODO get - throw if uninitialized
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

  /// Sets degrees of truth of a variable which has been assigned a crisp value.
  void _setDegreesOfTruthFromCrispValue() {
    variable.sets.forEach((set) =>
        set.setDegreeOfTruth(set.getDegreeOfMembership(_crispValue), [this]));
  }

  /// Compute the crisp value using the Average of Maxima method.
  void _computeCrispValue() {
    final numerator = variable.sets.fold<num>(
        0,
        (sum, fuzzySet) =>
            sum + (fuzzySet.representativeValue) * degreesOfTruth[fuzzySet]);
    final denominator =
        degreesOfTruth.values.fold<num>(0, (sum, dot) => sum + dot);
    if (denominator == 0) {
      // No confidence.
      _crispValue = null;
    } else if (T == int) {
      _crispValue = numerator ~/ denominator as T;
    } else {
      _crispValue = numerator / denominator as T;
    }
    _crispValueConfidence = degreesOfTruth.values.reduce(max);
  }

  /// Sets the degree of truth for a [FuzzySet] which is a part of this
  /// [FuzzyValue].
  void setDegreeOfTruth(FuzzySet<T> set, num degreeOfTruth) {
    assert(variable.sets.contains(set));
    var currentDegreeOfTruth = degreesOfTruth[set];
    if (currentDegreeOfTruth == null) {
      logger.fine('- setting degree of truth for $set to $degreeOfTruth');
      degreesOfTruth[set] = degreeOfTruth;
    } else if (currentDegreeOfTruth < degreeOfTruth) {
      logger.fine('- updating degree of truth for $set to $degreeOfTruth');
      degreesOfTruth[set] = degreeOfTruth;
    } else {
      logger.fine('- degree of truth for $set '
          'already higher than $degreeOfTruth '
          '(currently $currentDegreeOfTruth)');
    }
  }

  String visualizeInAscii() {
    final buf = StringBuffer();
    for (FuzzySet set in degreesOfTruth.keys) {
      buf.write('Set with representative value of ${set.representativeValue} ');
      buf.writeln(
          'has a degree if thruth = ${(degreesOfTruth[set] * 100).round()}');
    }
    return buf.toString();
  }
}
