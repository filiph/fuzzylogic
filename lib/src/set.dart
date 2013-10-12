part of fuzzylogic;

/**
 * FuzzySet is normally a fuzzy 'value' of a 'variable'.
 * 
 * Example: a fuzzy variable [:distance:] can have a value of [:short:] (and 
 * [:medium:] and [:long:]). The corresponding FuzzySet for [:distance.Short:] 
 * would be such that is [FuzzyTrue] for distances in range of 5 meters, then 
 * slopes towards [FuzzyFalse] for ranges 5-20 meters.
 */
class FuzzySet<T> extends FuzzyNode {
  
  num getDegreeOfMembership(List<FuzzyValue> inputs) {
    var fuzzyValue = inputs.singleWhere(
        (FuzzyValue value) => value.variable == this.variable);
    // TODO: for non-crisp values
    var dom = membershipFunction.getDegreeOfMembership(fuzzyValue.crispValue);
    return dom;
  }
  
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    outputs.where((fuzzyValue) => fuzzyValue.variable == this.variable)
      .forEach((fuzzyValue) {
        fuzzyValue.setDegreeOfTruth(this, degreeOfTruth);
      });
  }
  
  /**
   * Returns the domain of membership (DOM) of he given value.
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
  
  FuzzySet(this.membershipFunction, this.representativeValue);
  
  FuzzySet.Triangle(num floor, num peak, num ceiling) :
      membershipFunction = 
          new LinearManifold([[floor, 0], [peak, 1], [ceiling, 0]]),
      representativeValue = peak;
  
  FuzzySet.LeftShoulder(num minimum, num peak, num ceiling) :
      membershipFunction = 
          new LinearManifold([[peak, 1], [ceiling, 0]]),
      representativeValue = minimum + (peak - minimum) / 2;
  
  FuzzySet.RightShoulder(num floor, num peak, num maximum) :
      membershipFunction = 
          new LinearManifold([[floor, 0], [peak, 1]]),
      representativeValue = peak + (maximum - peak) / 2;
}

abstract class MembershipFunction<T> {
  num getDegreeOfMembership(T o);
}

