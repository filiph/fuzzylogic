import 'package:fuzzylogic/fuzzylogic.dart';
import 'package:fuzzylogic/fuzzyhedges.dart';

class Intelligence extends FuzzyVariable<int> {
  var Stupid = FuzzySet.LeftShoulder(0, 90, 100);
  var Average = FuzzySet.Triangle(90, 100, 110);
  var Clever = FuzzySet.RightShoulder(100, 110, 200);

  Intelligence() {
    sets = [Stupid, Average, Clever];
    init();
  }
}

class Workload extends FuzzyVariable<int> {
  var Manageable = FuzzySet.LeftShoulder(0, 40, 50);
  var VeryBusy = FuzzySet.RightShoulder(40, 50, 84);

  Workload() {
    sets = [Manageable, VeryBusy];
    init();
  }
}

class Amount extends FuzzyVariable<int> {
  var None = FuzzySet.LeftShoulder(0, 0, 1);
  var One = FuzzySet.Triangle(0, 1, 2);
  var Couple = FuzzySet.Triangle(1, 2, 4);
  var Many = FuzzySet.RightShoulder(2, 5, 10);

  Amount() {
    sets = [None, One, Couple, Many];
    init();
  }
}

void main() {
  var intelligence = Intelligence();
  var workload = Workload();
  var amountOfBooks = Amount();

  var frb = FuzzyRuleBase();
  frb.addRules([
    ((intelligence.Average | intelligence.Clever) &
            fairly(workload.Manageable)) >>
        (amountOfBooks.Couple),
    (intelligence.Stupid) >> (amountOfBooks.One),
    (very(intelligence.Stupid)) >> (amountOfBooks.None),
    (very(intelligence.Clever)) >> (amountOfBooks.Many),
    (very(workload.VeryBusy)) >> (amountOfBooks.None)
  ]);

  var amount = amountOfBooks.createOutputPlaceholder();

  frb.resolve(
      inputs: [intelligence.assign(100), workload.assign(40)],
      outputs: [amount]);
  print(amount.crispValue);
}
