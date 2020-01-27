uses scratch.IntcodeComputer
uses java.io.File
uses scratch.Util

/**
 * Day 7: Amplification Circuit
 * 
 * Ship's thrusters are controlled by a series(!) of five amplifiers.
 * Each amplifier contains an Intcode computer to run the control software.
 * 
 * The control program will read
 * 1) a phase setting
 * 2) an input signal
 * and output
 * 3) an output signal
 * 
 * There are four possible phase settings - 0, 1, 2, 3, 4 - which will each
 * be used exactly once. (Yes, it's permutations.)
 * Each amplifier's output signal becomes the next amplifier's input signal.
 * The first amplifier will have an input of 0. The last amplifier outputs to
 * the ship's thrusters.
 * 
 * Maximize the final thruster control value by finding the highest-performing
 * permutation of phase settings.
 * 
 * Input: an Intcode thruster control program.
 * 
 */

static class Amplifier {
  static var controlSoftwareSource = new File("src/main/gosu/days/Day7-input.txt")
  var computer : IntcodeComputer
  
  construct() {
    computer = new IntcodeComputer()
    computer.load(controlSoftwareSource)
  }
  
  function run(phase : int, input : int) : int {
    computer.reset()
    computer.
    computer.Input.add(input)
    computer.run()
    return computer.Output.first()
  }
}

var A = new Amplifier()
var B = new Amplifier()
var C = new Amplifier()
var D = new Amplifier()
var E = new Amplifier()

function checkInput(phase : int[]) : int {
  return E.run(phase[4], D.run(phase[3], C.run(phase[2], B.run(phase[1], A.run(phase[0], 0)))))
}

var samples = {
  
}
var phases : int[] = {0, 1, 2, 3, 4}

var maxThrust = Integer.MIN_VALUE
var bestOrder : int[]
for(n in 0..|Util.factorial(phases.Count)) {
  var phaseOrder = Util.permute(phases, Util.nthderangement(n, phases.Count))
  var thrust = checkInput(phaseOrder)
  if(thrust > maxThrust) {
    maxThrust = thrust
    bestOrder = phaseOrder
    print("new best: [${phaseOrder.join(", ")}] -> ${thrust}")
  }
}

