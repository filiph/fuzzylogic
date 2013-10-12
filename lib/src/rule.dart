part of fuzzylogic;

/**
 * FuzzyRule is a singular IF THEN rule. 
 */
class FuzzyRule {
  FuzzyNode antecedent;
  FuzzyNode consequent;
  
  FuzzyRule(this.antecedent, this.consequent);
  
  void resolve(List<FuzzyValue> inputs, List<FuzzyValue> outputs) {
    num degreeOfTruth = antecedent.getDegreeOfMembership(inputs);
    consequent.setDegreeOfTruth(degreeOfTruth, outputs);
  }
}