part of fuzzylogic;

/**
 * FuzzyRule is a singular IF THEN rule. It is normally a part of a 
 * [FuzzyRuleBase].
 */
class FuzzyRule {
  FuzzyNode antecedent;
  FuzzyNode consequent;
  
  FuzzyRule(this.antecedent, this.consequent);
  
  /**
   * Finds out the degree of membership (truth) of the antecedent and applies
   * it to the consequent.
   */
  void resolve(List<FuzzyValue> inputs, List<FuzzyValue> outputs) {
    num degreeOfTruth = antecedent.getDegreeOfMembershipWithInputs(inputs);
    consequent.setDegreeOfTruth(degreeOfTruth, outputs);
  }
}