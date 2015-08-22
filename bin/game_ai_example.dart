import 'package:fuzzylogic/fuzzylogic.dart';

class Distance extends FuzzyVariable<num> {
  var Close = new FuzzySet.LeftShoulder(0, 25, 150);
  var Medium = new FuzzySet.Triangle(25, 150, 300);
  var Far = new FuzzySet.RightShoulder(150, 300, 400);

  Distance() {
    sets = [Close, Medium, Far];
    init();
  }
}

class Ammo extends FuzzyVariable<int> {
  var Low = new FuzzySet.LeftShoulder(0, 0, 10);
  var Okay = new FuzzySet.Triangle(0, 10, 30);
  var Loads = new FuzzySet.RightShoulder(10, 30, 40);

  Ammo() {
    sets = [Low, Okay, Loads];
    init();
  }
}

class Desirability extends FuzzyVariable<num> {
  var Undesirable = new FuzzySet.LeftShoulder(0, 20, 50);
  var Desirable = new FuzzySet.Triangle(20, 50, 70);
  var VeryDesirable = new FuzzySet.RightShoulder(50, 70, 100);

  Desirability() {
    sets = [Undesirable, Desirable, VeryDesirable];
    init();
  }
}

main() {
  // Set up variables.
  var distanceToTarget = new Distance();
  var bazookaAmmo = new Ammo();
  var bazookaDesirability = new Desirability();

  // Add rules.
  var frb = new FuzzyRuleBase();
  frb.addRules([
    (distanceToTarget.Far & bazookaAmmo.Loads) >>
        (bazookaDesirability.Desirable),
    (distanceToTarget.Far & bazookaAmmo.Okay) >>
        (bazookaDesirability.Undesirable),
    (distanceToTarget.Far & bazookaAmmo.Low) >>
        (bazookaDesirability.Undesirable),
    (distanceToTarget.Medium & bazookaAmmo.Loads) >>
        (bazookaDesirability.VeryDesirable),
    (distanceToTarget.Medium & bazookaAmmo.Okay) >>
        (bazookaDesirability.VeryDesirable),
    (distanceToTarget.Medium & bazookaAmmo.Low) >>
        (bazookaDesirability.Desirable),
    (distanceToTarget.Close & bazookaAmmo.Loads) >>
        (bazookaDesirability.Undesirable),
    (distanceToTarget.Close & bazookaAmmo.Okay) >>
        (bazookaDesirability.Undesirable),
    (distanceToTarget.Close & bazookaAmmo.Low) >>
        (bazookaDesirability.Undesirable)
  ]);

  // Create the placeholder for output.
  var bazookaOutput = bazookaDesirability.createOutputPlaceholder();

  // Use the fuzzy inference engine.
  frb.resolve(
      inputs: [distanceToTarget.assign(200), bazookaAmmo.assign(8)],
      outputs: [bazookaOutput]);

  print(bazookaOutput.crispValue);
  print(bazookaOutput.confidence);
}
