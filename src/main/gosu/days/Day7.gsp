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

function parseLineOfLongs(line : String) : Long[] {
  return line.split(",").map(\text -> Long.parseLong(text.trim()))
}

var inputLocation = new File(
  System.Properties.getProperty("user.dir"),
  "src/main/gosu/days/Day7-input.txt"
)

var thruster_control_program : Long[]
thruster_control_program = parseLineOfLongs(inputLocation.read())
//thruster_control_program = parseLineOfInts("3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10")

function getThrusters() : IntcodeComputer[] {
  var amplifiers = new IntcodeComputer[5]
  for(i in 0..|amplifiers.length) {
    var controller = new IntcodeComputer()
    controller.load(thruster_control_program)
    controller.reset()
    amplifiers[i] = controller
  }
  return amplifiers
}

function checkInput(phase : Long[]) : long {
  var thrustSetting : long = 0 // initial
  var amplifiers = getThrusters()
  for(controller in amplifiers index i) controller.writeInput(phase[i])
  for(controller in amplifiers) {
    controller.writeInput(thrustSetting)
    controller.run()
    thrustSetting = controller.readOutput()
  }
  return thrustSetting
}

function checkInputWithFeedback(phase : Long[]) : long {
  // mostly the same
  var thrustSetting : Long = 0 // initial
  var amplifiers = getThrusters()
  for(controller in amplifiers index i) controller.writeInput(phase[i])
  var round = 0
  do {
    round += 1
    for(controller in amplifiers index i) {
      if(thrustSetting != null) controller.writeInput(thrustSetting)
      controller.run()
      thrustSetting = controller.readOutput()
      var state = {
        controller.Halt ? "1" : "0",
        controller.WaitingForInput ? "1" : "0",
        controller.WaitingForOutput ? "1" : "0"
      }.join("/")
      //print("amplifier ${{'A','B','C','D','E'}[i]} output ${thrustSetting} ${state}")
    }
    //print("round ${round} final output ${thrustSetting}")
  } while(not amplifiers.last().Halt)
  return thrustSetting
}

function latos(value : Long[]) : String {
  return "[${value.join(", ")}]"
}

function findBestInput(initialSetting : long, phases : Long[], test : block(order:Long[]):long) {
  var maxThrust = Long.MIN_VALUE
  var bestOrder : Long[]
  for(n in 0..|Util.factorial(phases.Count)) {
    var phaseOrder = Util.permute(phases.toList(), Util.nthderangement(n, phases.Count)).toTypedArray()
    var thrust = test(phaseOrder)
    if(thrust > maxThrust) {
      maxThrust = thrust
      bestOrder = phaseOrder
      print("new best: ${latos(phaseOrder)} -> ${thrust}")
    }
  }
  
  print("best input: ${latos(bestOrder)} -> ${maxThrust}")
}

var simplePhases : Long[] = {0, 1, 2, 3, 4}
print("find best order for phase settings ${latos(simplePhases)}")
findBestInput(0, simplePhases, \setting -> checkInput(setting))

var feedbackPhases : Long[] = {5, 6, 7, 8, 9}
print("find best order for phase settings ${latos(feedbackPhases)} with feedback")
findBestInput(0, feedbackPhases, \setting -> checkInputWithFeedback(setting))

// 3808978 too low // derp, this wasn't the best result, it was just the last one printed to the console!
