# Fuzzy Logic for Dart

This is a module for fuzzy logic in [Dart]. It takes some inspiration from the
[FCL (Fuzzy Control Language) IEC 1131-7 specification][FCLSpec], but otherwise
strives to be a 'Dart-y' way to create and work with fuzzy rules.

[FCLSpec]: http://www.fuzzytech.com/binaries/ieccd1.pdf
[Dart]: https://www.dartlang.org/

The goal of this project is to make it extremely easy to implement fuzzy
logic when creating:

1. Artificial intelligence in Web-based games.
2. Intelligent user experience in websites.

## Example of use

Here's code that implements the "Designing FLVs for Weapon Selection" (pp. 
425-437) fuzzy logic example from Mat Buckland's excellent book _[Programming
Game AI by Example (2005)][Buckland]._

[Buckland]: http://www.amazon.com/Programming-Game-Example-Mat-Buckland/dp/1556220782

    // Set up variables.
    var distanceToTarget = new Distance();
    var bazookaAmmo = new Ammo();
    var bazookaDesirability = new Desirability();
    
    // Add rules.
    var frb = new FuzzyRuleBase();
    frb.addRules([
        (distanceToTarget.Far & bazookaAmmo.Loads) >> (bazookaDesirability.Desirable),
        (distanceToTarget.Far & bazookaAmmo.Okay) >> (bazookaDesirability.Undesirable),
        (distanceToTarget.Far & bazookaAmmo.Low) >> (bazookaDesirability.Undesirable),
        (distanceToTarget.Medium & bazookaAmmo.Loads) >> (bazookaDesirability.VeryDesirable),
        (distanceToTarget.Medium & bazookaAmmo.Okay) >> (bazookaDesirability.VeryDesirable),
        (distanceToTarget.Medium & bazookaAmmo.Low) >> (bazookaDesirability.Desirable),
        (distanceToTarget.Close & bazookaAmmo.Loads) >> (bazookaDesirability.Undesirable),
        (distanceToTarget.Close & bazookaAmmo.Okay) >> (bazookaDesirability.Undesirable),
        (distanceToTarget.Close & bazookaAmmo.Low) >> (bazookaDesirability.Undesirable)
    ]);
    
    // Create the placeholder for output.
    var bazookaOutput = bazookaDesirability.createOutputPlaceholder();
    
    // Use the fuzzy inference engine.
    frb.resolve(
        inputs: [distanceToTarget.assign(200), bazookaAmmo.assign(8)], 
        outputs: [bazookaOutput]);
    
    print(bazookaOutput.crispValue);
    
There are two main components to the code example above. The setup phase 
consists of **setting up the fuzzy language variables (FLVs) and the rule set.**
This is normally done once per runtime only. The rest of the code is normally
run periodically, or every time a decision is needed. It consists of **creating
placeholder variable(s) and resolving them using the rule set and given (crisp)
values.** 

### Fuzzy Language Variables and Values

You can use the generic FuzzyVariable, but in most cases, you want to subclass
it as follows:

    class Distance extends FuzzyVariable<num> {
      var Close = new FuzzySet.LeftShoulder(0, 25, 150);
      var Medium = new FuzzySet.Triangle(25, 150, 300);
      var Far = new FuzzySet.RightShoulder(150, 300, 400);
      
      Distance() {
        sets = [Close, Medium, Far];
        init();
      }
    }
    
This creates a fuzzy language variable that can be then instantiated by calling
`distance = new Distance()`. It's fuzzy sets are accessed via `distance.Close`, 
`distance.Medium` and `distance.Far`. 

When decision is needed according to some crisp distance `n`, you create a 
fuzzy _value_ from the fuzzy _variable_ by calling `distance.assign(n)`. This
value is then passed to a FuzzyRuleBase `resolve()` method as input.

	var currentDistance = distance.assign(200);  // We are 200 meters away.
    frb.resolve(
        inputs: [currentDistance], 
        outputs: [bazookaOutput]);
        
### Fuzzy Rules

This library uses Dart's operator overloading for easier and more readable
definition of fuzzy rules.

    (distance.Far & ammo.Loads) >> (bazookaDesirability.Desirable)
    
Note that the overloaded operators are the _bitwise_ ones, not the boolean ones. 
It's `&` for logical AND, `|` for logical OR, and `~` for logical NOT (as 
opposed to `&&`, `||` and `!`). This is because the boolean operators cannot be
overridden, and – more importantly – the use of slightly different operands
helps convey the fact that this is _not_ boolean logic.

Dart will correctly issue a warning if you try to use the boolean operands to
construct a fuzzy rule.

Also note the `>>` operand, meaning THEN. It was chosen for its resemblance to
the [mathematical implication 
symbol](http://en.wikipedia.org/wiki/Material_conditional) (⇒). Because the 
operand has low precedence, **the antecedent and the conseqent (what comes 
before and after the symbol) need to be in brackets.**

Operator overloading tends to be controversial and can be very confusing. I am
hoping that in this case, its advantages clearly outweigh the disadvantages. You
will be writing a lot of rules in your fuzzy language modules. The more terse
the symbology, the more readable the rule.