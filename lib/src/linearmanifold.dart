part of fuzzylogic;

/**
 * Manifold provides degree of membership for fuzzy variables based on numerical
 * values.
 */
class LinearManifold implements MembershipFunction<num> {
  List<LinearManifoldSegment> segments;
  
  final num _lowest;
  final num _highest;
  
  LinearManifold(List<List<num>> inputList) :
      _lowest = inputList.first[0], _highest = inputList.last[0] {
    segments = new List<LinearManifoldSegment>();
    for (var i = 0; i < inputList.length - 1; i++) {
      var from = new LinearManifoldPoint(inputList[i][0], inputList[i][1]);
      var to = new LinearManifoldPoint(inputList[i+1][0], inputList[i+1][1]);
      segments.add(new LinearManifoldSegment(from, to));
    }
  }
  
  num getDegreeOfMembership(num crisp) {
    if (crisp <= _lowest) {
      return segments.first.from.degreeOfMembership;
    }
    if (crisp >= _highest) {
      return segments.last.to.degreeOfMembership;
    }
    return segments.firstWhere((var segment) => 
        segment.from.crisp <= crisp && segment.to.crisp >= crisp)
          .getDegreeOfMembership(crisp);
  }
}

class LinearManifoldSegment {
  final LinearManifoldPoint from;
  final LinearManifoldPoint to;
  
  LinearManifoldSegment(this.from, this.to);
  
  num getDegreeOfMembership(num crisp) {
    assert(crisp >= from.crisp);
    assert(crisp <= to.crisp);
    num a = from.degreeOfMembership;
    num b = to.degreeOfMembership;
    return a + (crisp - from.crisp) / (to.crisp - from.crisp) * (b - a);
  }
}

class LinearManifoldPoint {
  final num crisp;
  final num degreeOfMembership;
  
  LinearManifoldPoint(this.crisp, this.degreeOfMembership);
}
