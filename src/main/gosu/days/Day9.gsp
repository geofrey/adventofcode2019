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
var inputList = new ArrayList<Integer>()
while(inputStream.hasNext()) inputList.add(inputStream.nextInt())

var boost_program = inputList.toTypedArray()

var computer = new IntcodeComputer()
computer.load(boost_program)