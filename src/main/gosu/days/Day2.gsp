uses java.io.FileInputStream
uses java.io.File
uses gw.util.Pair
uses scratch.IntCodeComputer

/**
 * Day 2: 1202 Program Alarm
 * 
 * Intcode computer
 * 4-part instructions: Opcode, A, B, X
 * Opcode specifies behavior
 * A and B are operand addresses
 * X is result destination address
 * 
 * Opcode 1: add
 * Opcode 2: multiply
 * 
 * Day 2, part 2: reverse-engineering
 * The given program takes parameters at addresses 1 and 2 and leaves its result at address 0.
 * Find the parameter values X and Y that produce an output of 19690720.
 * Puzzle solution is 100 * X + Y.
 * Parameter values will be in [0, 99]
 */



var inputPath = "c:/Users/gsanders/Desktop/Projects/adventofcode2019/src/main/gosu/days/Day2-input.txt"
var input =
  new File(inputPath).read()
  //"1,9,10,3,2,3,11,0,99,30,40,50" // example 1 PASS
  //"1,0,0,0,99" // sample 1 PASS
  //"2,3,0,3,99" // sample 2 PASS
  //"2,4,4,5,99,0" // sample 3 PASS
  //"1,1,1,4,99,5,6,0,99" // sample 4 PASS
  
var program = input.split(",").map(\text -> Integer.parseInt(text.trim()))

var computer = new IntCodeComputer()
computer.Debug = false

// setup
computer.load(program)
computer.poke(1, 12)
computer.poke(2, 2)

computer.reset()
computer.run()

var outcome = computer.peek(0)
print("\"1202 program alarm\" execution result = ${outcome}")

var target = 19690720
    target = 19690720
var solutions = new ArrayList<Pair<Integer,Integer>>()
for(X in 0..99) {
  for(Y in 0..99) {
    //print("${X}/${Y}")
    computer.load(program)
    computer.poke(1, X)
    computer.poke(2, Y)
    computer.reset()
    computer.run()
    var result = computer.peek(0)
    if(result == target) {
      var solution = Pair.make(X, Y)
      print("solution: ${solution}")
      solutions.add(solution)
    }
  }
}
for(solution in solutions) {
  var X = solution.First
  var Y = solution.Second
  print("${X}/${Y} -> ${100 * X + Y}")
}
