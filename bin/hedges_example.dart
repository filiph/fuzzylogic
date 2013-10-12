import 'package:fuzzylogic/fuzzylogic.dart';
import 'package:fuzzylogic/fuzzyhedges.dart';

class Intelligence extends FuzzyVariable<int> {
  var Stupid = new FuzzySet.LeftShoulder(0, 90, 100);
  var Average = new FuzzySet.Triangle(90, 100, 110);
  var Clever = new FuzzySet.RightShoulder(100, 110, 200);
  
  Intelligence() {
    sets = [Stupid, Average, Clever];
    init();
  }
}

class Workload extends FuzzyVariable<int> {
  var Manageable = new FuzzySet.LeftShoulder(0, 40, 50);
  var VeryBusy = new FuzzySet.RightShoulder(40, 50, 84);
  
  Workload() {
    sets = [Manageable, VeryBusy];
    init();
  }
}

class Amount extends FuzzyVariable<int> {
  var None = new FuzzySet.LeftShoulder(0, 0, 1);
  var One = new FuzzySet.Triangle(0, 1, 2);
  var Couple = new FuzzySet.Triangle(1, 2, 4);
  var Many = new FuzzySet.RightShoulder(2, 5, 10);
  
  Amount() {
    sets = [None, One, Couple, Many];
    init();
  }
}

main() {
  var intelligence = new Intelligence();
  var workload = new Workload();
  var amountOfBooks = new Amount();
  
  var frb = new FuzzyRuleBase();
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
  
  frb.resolve(inputs: [intelligence.assign(100), workload.assign(40)],
      outputs: [amount]);
  print(amount.crispValue);
}