part of fuzzylogic;

class FuzzyRuleBase {
  Set<FuzzyRule> rules = new Set();
  
  void addRule(FuzzyRule fr) => rules.add(fr);
  void addRules(List<FuzzyRule> frs) => rules.addAll(frs);
  
  void resolve({List<FuzzyValue> inputs, List<FuzzyValue> outputs}) {
    // TODO: infer what rules to run based on outputs
    
    rules.forEach((rule) => rule.resolve(inputs, outputs));
  }
}