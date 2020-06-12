part of fuzzylogic;

/// [FuzzyRuleBase] is the set of all rules pertaining to a particular fuzzy
/// control system. Normally, it is initialized once and then it's [resolve]
/// method is called every time a control decision is needed.
///
/// Example of use:
///
///     // Initialize FuzzyVariables (distance, ammo, bazzokaDesirability) first.
///     // ...
///
///     // Add rules.
///     var frb = new FuzzyRuleBase();
///     frb.addRules([
///       (distance.Far & ammo.Loads) >> (bazookaDesirability.Desirable)
///       (distance.Close & ammo.Loads) >> (bazookaDesirability.Undesirable)
///       // ...
///     ]);
///
///     // ...
///
///     // Create the placeholder for output.
///     var bazookaOutput = bazookaDesirability.createOutputPlaceholder();
///
///     // Create FuzzyValues from FuzzyVariables by assigning crisp values to
///     // them. Then resolve the rule base by inputing the FuzzyValues as
///     // inputs.
///     frb.resolve(
///         inputs: [distanceToTarget.assign(200), bazookaAmmo.assign(8)],
///         outputs: [bazookaOutput]);
///
///     // Access the result.
///     print(bazookaOutput.crispValue);
class FuzzyRuleBase {
  Set<FuzzyRule> rules = {};

  void addRule(FuzzyRule fr) {
    rules.add(fr);
  }

  void addRules(List<FuzzyRule> frs) => rules.addAll(frs);

  void resolve({List<FuzzyValue> inputs, List<FuzzyValue> outputs}) {
    // TODO: infer what rules to run based on outputs
    for (final output in outputs) {
      if (output.crispValue != null) {
        throw FuzzyLogicStateError("Can't use output value twice.");
//        logger.warning("Shouldn't be using output value twice.");
      }
    }

    rules.forEach((rule) => rule.resolve(inputs, outputs));
  }
}
