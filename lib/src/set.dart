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
  
  /**
   * The most generic constructor. The crisp values don't need to be numeric
   * (e.g. they can be objects of custom classes) - the only restriction is that
   * a [MembershipFunction] is given that can convert a crisp value to a degree
   * of membership, and a [representativeValue] is given for the set.
   */
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
  
  FuzzySet.Trapezoid(num floor, num peakStart, num peakEnd, num maximum) :
      membershipFunction = 
          new LinearManifold([
              [floor, 0], [peakStart, 1], [peakEnd, 1], [maximum, 0]
          ]),
      representativeValue = peakStart + (peakEnd - peakStart) / 2;
}

abstract class MembershipFunction<T> {
  num getDegreeOfMembership(T o);
}
