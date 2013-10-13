/**
 * By importing this library, you get the two most important fuzzy logic hedges:
 * [very] and [fairly].
 * 
 * This means you can do:
 * 
 *     (fairly(joke.funny) & very(situation.tense)) >> (laughter.loud)
 */
library fuzzyhedges;

import 'fuzzylogic.dart';
import 'dart:math';

class _FuzzyHedge extends FuzzyTerm {
  _FuzzyHedge(FuzzyNode a, this.hedgeFunction) {
    children = new Set.from([a]);
  }
  
  final _HedgeFunction hedgeFunction;
  
  num getDegreeOfMembershipWithInputs(List<FuzzyValue> inputs) {
    return hedgeFunction(children.single.getDegreeOfMembershipWithInputs(inputs));
  }
  
  void setDegreeOfTruth(num degreeOfTruth, List<FuzzyValue> outputs) {
    // TODO: change DOT through hedgeFunction?
    children.single.setDegreeOfTruth(degreeOfTruth, outputs);
  }
}

typedef num _HedgeFunction(num degreeOfMembership);

FuzzyNode very(FuzzyNode node) => 
    new _FuzzyHedge(node, (num dom) => pow(dom, 2));
FuzzyNode fairly(FuzzyNode node) => 
    new _FuzzyHedge(node, (num dom) => sqrt(dom));