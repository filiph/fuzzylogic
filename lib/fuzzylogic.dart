library FuzzyLogic;

import 'dart:math';

/**
 * A node is a part of a fuzzy expression.
 */
abstract class FuzzyNode extends Object {
  FuzzyNode parent;
  Set<FuzzyNode> children;
  
  bool get isRoot => parent == null;
  bool get isLeaf => children == null || children.isEmpty;
  
  // TODO: containsVariable? recursive function
  
  num getDegreeOfMembership(List<FuzzyValue> inputs);
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs);
}

/**
 * A FuzzyTerm includes one or more FuzzyVariables and combines their values 
 * or manifolds into one.
 * 
 * Examples: AND, OR and NOT.
 */
abstract class FuzzyTerm extends Object with FuzzyNode {
  
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

// TODO: _FuzzyVery and _FuzzyFairly

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

/**
 * FuzzyValue is a FuzzyVariable that is initialized.
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
      throw new StateError("Cannot compute AvMax for non-numeric values.");
    }
    _crispValueConfidence = degreesOfTruth.values.reduce(max);
  }
  
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

/**
 * FuzzySet is normally a fuzzy 'value' of a 'variable'.
 * 
 * Example: a fuzzy variable [:distance:] can have a value of [:short:] (and 
 * [:medium:] and [:long:]). The corresponding FuzzySet for [:distance.Short:] 
 * would be such that is [FuzzyTrue] for distances in range of 5 meters, then 
 * slopes towards [FuzzyFalse] for ranges 5-20 meters.
 */
class FuzzySet<T> extends Object with FuzzyNode {
  
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
  
  operator &(FuzzySet other) => new _FuzzyAnd(this, other);
  operator |(FuzzySet other) => new _FuzzyOr(this, other);
  operator ~() => new _FuzzyNot(this);
}

abstract class MembershipFunction<T> {
  num getDegreeOfMembership(T o);
}

class FuzzyRuleBase {
  Set<FuzzyRule> rules = new Set();
  
  void addRule({FuzzyNode antecedent, FuzzyNode consequent}) {
    assert(antecedent != null);
    assert(consequent != null);
    rules.add(new FuzzyRule(antecedent, consequent));
  }
  
  void resolve({List<FuzzyValue> inputs, List<FuzzyValue> outputs}) {
    // TODO: infer what rules to run based on outputs
    
    rules.forEach((rule) => rule.resolve(inputs, outputs));
  }
}

class FuzzyRule {
  FuzzyNode antecedent;
  FuzzyNode consequent;
  
  FuzzyRule(this.antecedent, this.consequent);
  
  void resolve(List<FuzzyValue> inputs, List<FuzzyValue> outputs) {
    num degreeOfTruth = antecedent.getDegreeOfMembership(inputs);
    consequent.setDegreeOfTruth(degreeOfTruth, outputs);
  }
}






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


