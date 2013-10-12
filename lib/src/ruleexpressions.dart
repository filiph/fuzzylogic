part of fuzzylogic;

/**
 * A node is the basic building block of a fuzzy rule expression.
 */
abstract class FuzzyNode {
  FuzzyNode parent;
  Set<FuzzyNode> children;
  
  bool get isRoot => parent == null;
  bool get isLeaf => children == null || children.isEmpty;
  
  FuzzyRule operator >>(FuzzyNode antecedent) {
    return new FuzzyRule(this, antecedent);
  }
  
  bool containsVariable(FuzzyVariable variable) {
    if (isLeaf) {
      assert(this is FuzzySet);
      return (this as FuzzySet).variable == variable;
    } else {
      assert(this is FuzzyTerm);
      return children.any((node) => node.containsVariable(variable));
    }
  }
  
  num getDegreeOfMembership(List<FuzzyValue> inputs);
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs);
  
  FuzzyNode operator &(FuzzyNode other) => new _FuzzyAnd(this, other);
  FuzzyNode operator |(FuzzyNode other) => new _FuzzyOr(this, other);
  FuzzyNode operator ~() => new _FuzzyNot(this);
}

/**
 * A FuzzyTerm includes one or more FuzzyVariables and combines their values 
 * or manifolds into one.
 * 
 * Examples: AND, OR and NOT.
 */
abstract class FuzzyTerm extends FuzzyNode {
  
}

/**
 * Corresponds to logical AND in fuzzy logic.
 */
class _FuzzyAnd extends FuzzyTerm {
  _FuzzyAnd(FuzzyNode a, FuzzyNode b) {
    children = new Set.from([a, b]);
  }
  
  num getDegreeOfMembership(List<FuzzyValue> inputs) {
    num minimum = children.fold(null, (num value, FuzzyNode n) {
      num dom = n.getDegreeOfMembership(inputs);
      if (value == null) return dom;
      if (dom < value) return dom;
      return value;
    });
    return minimum;
  }
  
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    children.forEach((node) => node.setDegreeOfTruth(degreeOfTruth, outputs));
  }
}

/**
 * Corresponds to logical OR in fuzzy logic.
 */
class _FuzzyOr extends FuzzyTerm {
  _FuzzyOr(FuzzyNode a, FuzzyNode b) {
    children = new Set.from([a, b]);
  }
  
  num getDegreeOfMembership(List<FuzzyValue> inputs) {
    num maximum = children.fold(null, (num value, FuzzyNode n) {
      num dom = n.getDegreeOfMembership(inputs);
      if (value == null || value < dom) return dom;
    });
    return maximum;
  }
  
  num _degreeOfTruth;
  
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    // Cannot say for sure which one is truthful.
    _degreeOfTruth = degreeOfTruth;
  }
}

/**
 * Corresponds to logical NOT in fuzzy logic.
 */
class _FuzzyNot extends FuzzyTerm {
  _FuzzyNot(FuzzyNode a) {
    children = new Set.from([a]);
  }
  
  num getDegreeOfMembership(List<FuzzyValue> inputs) {
    return (1 - children.single.getDegreeOfMembership(inputs));
  }
  
  num _degreeOfTruth;
  
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    // Cannot say for sure what this means for the underlying child. TODO
    _degreeOfTruth = degreeOfTruth;
  }
}