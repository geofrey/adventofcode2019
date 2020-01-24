uses scratch.IntcodeComputer
uses java.io.File

/**
 * Day 5: Sunny with a Chance of Asteroids
 * 
 * Intcode computer now has input and output...buffers, I guess.
 * Opcode 3: remove one int from input and store it in memory
 * Opcode 4: read one int from memory and add it to output
 * 
 * Incode instructions come with addressing mode for their input parameters
 * First two (base-10) digits are the opcode. Subsequent place values, in
 * increasing order, are the instruction's parameters' modes.
 * 0: position mode - the parameter is an address from which to fetch an operand
 * 1: immediate mode - the parameter is the operand
 * 
 * Challenge input is an Intcode diagnostic program.
 */

var computer = new IntcodeComputer()
computer.Debug = true

var testPrograms = {
  "1,9,10,3,2,3,11,0,99,30,40,50",
  "1,0,0,0,99",
  "2,3,0,3,99",
  "2,4,4,5,99,0",
  "1,1,1,4,99,5,6,0,99",
  "1002,4,3,4,33",
  "3,0,4,0,99"
}.map(\line -> line.split(",").map(\text -> Integer.parseInt(text.trim())))
for(test in testPrograms) {
  computer.reset()
  computer.Input.add(1)
  computer.load(test)
  computer.run()
  print("")
}


var inputLocation = "c:/Users/gsanders/Desktop/Projects/adventofcode2019/src/main/gosu/days/Day5-input.txt"
var diagnostic = new File(inputLocation).read().split(",").map(\text -> Integer.parseInt(text.trim()))

computer.Debug = false

for(systemCode in {1, 5}) {
  print("run diagnostic on system ${systemCode}")
  computer.reset()
  computer.load(diagnostic)
  computer.run()
  while(computer.WaitingForInput) {
    computer.Input.add(systemCode)
    computer.run()
  }

  for(o in 0..|computer.Output.Count-1 index i) {
    var result = computer.Output.get(o)
    print("diagnostic ${i}: ${result} - ${result == 0 ? "PASS" : "FAIL"}")
  }
  print("final diagnostic code, system ${systemCode}: ${computer.Output.last()}")
}


