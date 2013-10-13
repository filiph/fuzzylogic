part of fuzzylogic;

/**
 * Manifold provides degree of membership for fuzzy variables based on numerical
 * values.
 * 
 * LinearManifold is modeling the most widely used fuzzification method - linear
 * "line segments" that together form a shape like a triangle, a shoulder or
 * a trapezoid.
 */
class LinearManifold implements MembershipFunction<num> {
  List<_LinearManifoldSegment> segments;
  
  final num _lowestCrispValue;
  final num _highestCrispValue;
  
  /**
   * The default constructor takes a list of tuples as its input, and is modeled
   * after FCL's set definition syntax.
   * 
   * Example: A trapezoid manifold starting at 2, plateauing between 5 and 6 
   * and ending at 12 would be created as follows:
   * 
   *     var trapezoid = new LinearManifold([[2,0], [5,1], [6,1], [12,0]]);
   */
  LinearManifold(List<List<num>> inputList) :
      _lowestCrispValue = inputList.first[0], 
      _highestCrispValue = inputList.last[0] {
    segments = new List<_LinearManifoldSegment>();
    for (var i = 0; i < inputList.length - 1; i++) {
      var from = new _LinearManifoldPoint(inputList[i][0], inputList[i][1]);
      var to = new _LinearManifoldPoint(inputList[i+1][0], inputList[i+1][1]);
      segments.add(new _LinearManifoldSegment(from, to));
    }
  }
  
  num getDegreeOfMembership(num crisp) {
    if (crisp <= _lowestCrispValue) {
      return segments.first.from.degreeOfMembership;
    }
    if (crisp >= _highestCrispValue) {
      return segments.last.to.degreeOfMembership;
    }
    return segments.firstWhere((var segment) => 
        segment.from.crisp <= crisp && segment.to.crisp >= crisp)
          .getDegreeOfMembership(crisp);
  }
}

class _LinearManifoldSegment {
  final _LinearManifoldPoint from;
  final _LinearManifoldPoint to;
  
  _LinearManifoldSegment(this.from, this.to);
  
  num getDegreeOfMembership(num crisp) {
    assert(crisp >= from.crisp);
    assert(crisp <= to.crisp);
    num a = from.degreeOfMembership;
    num b = to.degreeOfMembership;
    return a + (crisp - from.crisp) / (to.crisp - from.crisp) * (b - a);
  }
}

class _LinearManifoldPoint {
  final num crisp;
  final num degreeOfMembership;
  
  _LinearManifoldPoint(this.crisp, this.degreeOfMembership);
}
