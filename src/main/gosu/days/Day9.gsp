uses scratch.Util
uses scratch.IntcodeComputer

/**
 * Day 9: Sensor Boost
 * 
 * Intcode computer needs relative parameter mode
 * - computer has a [relative base]
 * - opcode 9 changes the relative base.
 * - - one parameter
 * - parameter mode 2 means relative addressing - fetch value from memory at parameter + relative base
 * 
 */

var inputStream = new Scanner(Util.getPuzzleInput("Day9-input.txt")).useDelimiter(",")
var inputList = new ArrayList<Long>()
while(inputStream.hasNextLong()) inputList.add(inputStream.nextLong())

var boost_program = inputList.toTypedArray()

var computer = new IntcodeComputer()

var testprograms = {
  "109,1,204,-1,1001,20,1,20,1008,20,16,21,1006,21,0,99", // modified addresses
  "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99", // allegedly a Quine
  "1102,34915192,34915192,7,4,7,99,0" // "a sixteen-digit number"
  ,"104,1125899906842624,99" // output that second number
  ,"109,5,203,2,4,7,99,0" // instruction 203, input with relative parameter
  ,"1105,1,3,99"
  ,"1105,0,3,98,99"
}

computer.Debug = true
for(program in testprograms index i) {
  print("test program ${i}")
  computer.load(program)
  computer.reset()
  computer.writeInput(1) // keep things happy
  //for(1..100) computer.execute()
  computer.run()
  print(computer.dumpOutput())
  print("")
}

print("BOOST diagnostic")
computer.load(boost_program)
computer.reset()
computer.Debug = false
computer.writeInput(1)
computer.run()
print(computer.dumpOutput())

print("\nBOOST sensor-boost program")
computer.load(boost_program)
computer.reset()
computer.writeInput(2)
computer.run()
print(computer.dumpOutput())

