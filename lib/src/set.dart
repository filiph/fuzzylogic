part of fuzzylogic;

/**
 * FuzzySet is a set whose values have degrees of membership.
 * 
 * Example: a fuzzy variable [:distance:] can have a fuzzy set of [:short:] (and 
 * [:medium:] and [:long:]). The corresponding FuzzySet for [:distance.Short:] 
 * would be such that is [FuzzyTrue] for distances in range of 5 meters, then 
 * slopes towards [FuzzyFalse] for ranges 5-20 meters (for example).
 */
class FuzzySet<T> extends FuzzyNode {

  /**
   * Finds the crisp value using the given [inputs], then finds the degree
   * of membership of that crisp value in the set. 
   */
  num getDegreeOfMembershipWithInputs(List<FuzzyValue> inputs) {
    var fuzzyValue = inputs
        .singleWhere((FuzzyValue value) => value.variable == this.variable);

    logger.fine("- getting degree of membership for " + _nameOrUnnamed(variable.name, "FuzzyVariable"));

    // TODO: for non-crisp values
    return getDegreeOfMembership(fuzzyValue.crispValue);
  }

  /**
   * Finds the degree of membership of a given crisp value in the set.
   */
  num getDegreeOfMembership(T crispValue) {
    var dom = membershipFunction.getDegreeOfMembership(crispValue);
    logger.fine("- degree of membership for " + _nameOrUnnamed(name, "set") + " (repr=$representativeValue) is ${(dom * 100).round()}");
    return dom;
  }

  /**
   * When the FuzzyValue (of which this FuzzySet is a part) is in the
   * consequent of a FuzzyRule, it will be assigned a degree of truth according
   * to the degree of truth of the antecedent. 
   */
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    outputs
        .where((fuzzyValue) => fuzzyValue.variable == this.variable)
        .forEach((fuzzyValue) {
      fuzzyValue.setDegreeOfTruth(this, degreeOfTruth);
    });
  }

  /**
   * Returns the domain of membership (DOM) of the given value.
   */
  final MembershipFunction<T> membershipFunction;

  /**
   * The crisp value most representative of this set.
   */
  final T representativeValue;

  /**
   * The FLV of which this fuzzy set is a part.
   */
  FuzzyVariable<T> variable;

  /**
   * Optional name of the fuzzy set (for logging).
   */
  String name;

  toString() {
    if (variable.name == null) return "FuzzySet<$name>";
    return "${variable.name}<$name>";
  }

  /**
   * The most generic constructor. The crisp values don't need to be numeric
   * (e.g. they can be objects of custom classes) - the only restriction is that
   * a [MembershipFunction] is given that can convert a crisp value to a degree
   * of membership, and a [representativeValue] is given for the set.
   */
  FuzzySet(this.membershipFunction, this.representativeValue,
           [this.name]);

  FuzzySet.Triangle(num floor, num peak, num ceiling, [this.name])
      : membershipFunction = new LinearManifold(
          [[floor, 0], [peak, 1], [ceiling, 0]]),
        representativeValue = peak;

  FuzzySet.LeftShoulder(num representative, num peak, num ceiling, [this.name])
      : membershipFunction = new LinearManifold([[peak, 1], [ceiling, 0]]),
        representativeValue = representative;

  FuzzySet.RightShoulder(num floor, num peak, num representative, [this.name])
      : membershipFunction = new LinearManifold([[floor, 0], [peak, 1]]),
        representativeValue = representative;

  FuzzySet.Trapezoid(num floor, num peakStart, num peakEnd, num maximum, [this.name])
      : membershipFunction = new LinearManifold(
          [[floor, 0], [peakStart, 1], [peakEnd, 1], [maximum, 0]]),
        representativeValue = peakStart + (peakEnd - peakStart) / 2;
}

abstract class MembershipFunction<T> {
  num getDegreeOfMembership(T o);
}
