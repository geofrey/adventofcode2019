/**
 * SPACE CHEMISTRY
 * 
 * Input is a set of available chemical reactions.
 * Reactions are all combinations - multiple inputs, one output (but possibly more than one unit)
 */

static class Ingredient {
  var count : long
  var name : String
  construct(quantity : long, species : String) {
    count = quantity
    name = species
  }
  override function toString() : String {
    return "${count} ${name}"
  }
  
  function copy() : Ingredient {
    return new Ingredient(count, name)
  }
}

static class Reaction {
  var reagents : List<Ingredient>
  var products : List<Ingredient>
  construct(ingredients : List<Ingredient>, yield : List<Ingredient>) {
    reagents = ingredients // the hardest part of programming is coming up with synonymous variable names
    products = yield
  }
  
  // 2 RXSZS, 10 MBFK, 1 BPNVK => 2 GZLHP
  static var formulaPattern = java.util.regex.Pattern.compile("(?<reagents>.*)=>(?<products>.*)")
  static var ingredientPattern = java.util.regex.Pattern.compile("(?<count>\\d+) (?<name>\\w+)")
  static function parse(line : String) : Reaction {
    var halfMatcher = formulaPattern.matcher(line)
    halfMatcher.matches()
    
    var reagents : List<Ingredient> = {}
    var ingredientMatcher = ingredientPattern.matcher(halfMatcher.group("reagents"))
    while(ingredientMatcher.find()) reagents.add(new Ingredient(Long.parseLong(ingredientMatcher.group("count")), ingredientMatcher.group("name")))
    
    var products : List<Ingredient> = {}
    ingredientMatcher.reset(halfMatcher.group("products"))
    while(ingredientMatcher.find()) products.add(new Ingredient(Long.parseLong(ingredientMatcher.group("count")), ingredientMatcher.group("name")))
  
    return new Reaction(reagents, products)
  }
  override function toString() : String {
    return "${reagents.join(", ")} => ${products.join(", ")}"
  }
  
  function simplify() {
    //reagents = reagents.partition(\reagent -> reagent.name).entrySet().map(\entry -> new Ingredient(entry.Value*.count.sum(), entry.Key))
    reagents = reagents.partition(\reagent -> reagent.name).entrySet().map(\entry -> {
      var count = entry.Value*.count.sum()
      var name = entry.Key
      return new Ingredient(count, name)
    })
  }
  function copy() : Reaction {
    return new Reaction(reagents.map(\ingredient -> ingredient.copy()), products.copy())
  }
  function ready(materials : Inventory) : boolean {
    return reagents.allMatch(\reagent -> materials.have(reagent))
  }
  function consumes(material : String) : Long {
    return reagents.firstWhere(\reagent -> reagent.name == material).count
  }
  function yields(material : String) : Long {
    return products.firstWhere(\product -> product.name == material).count
  }
}

static class Library {
  var reactions : Set<Reaction>
  
  construct(possibleReactions : Set<Reaction>) {
    reactions = possibleReactions
  }
  
  static function load(source : java.io.File) : Library {
    var fileReader = new java.io.BufferedReader(new java.io.FileReader(source))
    var inputLines = new scratch.Generator(\-> fileReader.readLine()?.trim())
    return load(inputLines)
  }
  static function load(inputLines : Iterator<String>) : Library {
    var reactions : Set<Reaction> = {}
    new scratch.Maperator(inputLines, \line -> Reaction.parse(line)).forEachRemaining(\reaction -> reactions.add(reaction))
    return new Library(reactions)
  }
  
  override function toString() : String {
    var buffer = new StringBuilder()
    for(reaction in reactions) {
      buffer.append(reaction as String)
      buffer.append("\n")
    }
    return buffer.toString()
  }
  
  function source(material : String) : Set<Reaction> {
    return reactions.where(\reaction -> reaction.products*.name.contains(material)).toSet()
  }
  
  function copy() : Library {
    return new Library(reactions)
  }
}

static class Inventory {
  var store : Map<String, Long>
  construct() {
    store = {}
  }
  
  function count(material : String) : Long {
    return store.getOrDefault(material, 0)
  }
  function have(item : Ingredient) : boolean {
    return count(item.name) >= item.count
  }
  function update(material : String, count : Long) : Long {
    var have = store.getOrDefault(material, 0)
    if(have + count < 0) throw new SupplyException("insufficient ${material} available (${have} + ${count})")
    return store.put(material, have + count)
  }
  function withdraw(material : String, count : Long) : Long {
    var available = Math.min(count, count(material))
    return update(material, -available)
  }
  function enumerate() : List<Ingredient> /* in no particular order */ {
    return store.entrySet().map(\entry -> new Ingredient(entry.Value, entry.Key)).where(\component -> component.count != 0)
  }
  function subtract(that : Inventory) : Inventory {
    var difference = this.copy()
    for(item in that.store.Keys) difference.withdraw(item, that.count(item))
    difference.prune()
    return difference
  }
  function prune() {
    for(empty in store.entrySet().where(\entry -> entry.Value == 0)) store.remove(empty.Key)
  }
  
  override function toString() : String {
    return store.toString()
  }
  function copy() : Inventory {
    var duplicate = new Inventory() { :store = this.store.copy() }
    duplicate.prune()
    return duplicate
  }
}

static class StoichiometricException extends Exception {
  construct(message : String) { super(message) }
}
static class SupplyException extends Exception {
  construct(message : String) { super(message) }
}

function produce(goal : Ingredient, reactions : Library, inventory : Inventory, bailout : int) : boolean {
  print("produce: ${goal}")
  print("have: ${inventory}")
  //print("reactions: ${reactions}")
  var patience = bailout
  while(not inventory.have(goal)) {
    patience -= 1
    if(patience < 1) {
      print("this is taking too long")
      return true
    }
    
    var candidatePaths = reactions.source(goal.name).toList()
    var immediates = candidatePaths.where(\reaction -> reaction.ready(inventory))
    if(immediates.HasElements) candidatePaths = immediates // prefer reactions we can perform now
    if(candidatePaths.Empty) {
      print("${goal.name} is unobtainable")
      return false// give up
    }
    var path = candidatePaths.minBy(\maybe -> Math.abs(goal.count - maybe.yields(goal.name) + 1))
  
    while(not path.ready(inventory)) {
      for(required in path.reagents) {
        var ready = inventory.count(required.name)
        //print("need ${required}, have ${ready}")
        var needed = required.count - ready
        if(needed > 0) {
          print("first, make ${required}")
          if(not produce(required, reactions, inventory, patience)) return false
        }
      }
    }
    
    print("perform reaction ${path}")
    path.reagents.each(\required -> inventory.update(required.name, -required.count))
    path.products.each(\yield -> inventory.update(yield.name, yield.count))
    //print(inventory)
    print("")
  }
  return true
}

function tryToProduce(goal : Ingredient, reactions : Library, inventory : Inventory) {
  reactions = reactions.copy()
  while(inventory.count(goal.name) < goal.count) {
    var snapshot = inventory.copy()
    try {
      var success = produce(goal, reactions, inventory, 100) // part one
      if(not success) {
        print("processing failed")
        return
      }
    } catch(YOUMUSTCOLLECTADDITIONALMINERALS : SupplyException) {
      print("stores exhausted: ${YOUMUSTCOLLECTADDITIONALMINERALS}")
    } catch(YOUCANTGETTHEREFROMHERE : StoichiometricException) {
      print("you ask the impossible: ${YOUCANTGETTHEREFROMHERE}")
    }
    print(inventory)
    
    var consumed = snapshot.subtract(inventory).enumerate()
    var produced = inventory.subtract(snapshot).enumerate()
    if(produced.Empty) {
      print("no progress, give up")
      return
    }
    var shortcutRecipe = new Reaction(consumed, produced)
    print("summary reaction ${shortcutRecipe}")
    reactions.reactions.add(shortcutRecipe)
  }
}

var sample1 = "10 ORE => 10 A\
1 ORE => 1 B\
7 A, 1 B => 1 C\
7 A, 1 C => 1 D\
7 A, 1 D => 1 E\
7 A, 1 E => 1 FUEL"

var library =
  Library.load(scratch.Util.getPuzzleInputFile("Day14-input.txt"))
  //Library.load(sample1.split("\n").toList().iterator())
print(library)

var initialInventory = new Inventory()
initialInventory.update("ORE", 1000000000000) // one trillion
var onHand = initialInventory.copy()


print("part one, how much ORE is required to make 1 FUEL?")
tryToProduce(new Ingredient(1, "FUEL"), library, onHand)
print("products ${onHand}")
print("ORE consumed ${initialInventory.count("ORE") - onHand.count("ORE")}")
// 1 FUEL : 654909 ORE consumed
print("")


print("part two, how much FUEL can we make with one trillion(!) units of ORE?")
tryToProduce(new Ingredient(9999999999999, "FUEL"), library, onHand)
print("FUEL produced: ${onHand.count("FUEL")}")
print("ORE remaining: ${onHand.count("ORE")}")

print("(try again...trust me)")
tryToProduce(new Ingredient(9999999999999, "FUEL"), library, onHand)
print("FUEL produced: ${onHand.count("FUEL")}")
print("ORE remaining: ${onHand.count("ORE")}")

