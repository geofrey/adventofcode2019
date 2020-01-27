package scratch
uses java.io.File

class IntcodeComputer {
  function dprint(msg : String) {
    if(debug) print(msg)
  }
  
  // basics
  var memory : Integer[]
  var PC : int
  
  // flags
  var halt : boolean as Halt
  var waitingForInput : boolean as WaitingForInput
  var waitingForOutput : boolean as WaitingForOutput
  var debug : boolean as Debug = false
  
  // IO
  var input : LinkedList<Integer>
  var output : LinkedList<Integer>
  var outputAction : block(value:int) : boolean as OutputCallback
  var inputAction : block() : Integer as InputCallback
  
  construct() {
    input = new LinkedList<Integer>()
    output = new LinkedList<Integer>()
    outputAction = \value -> output.add(value)
    inputAction = \-> input.HasElements ? input.remove() : null
  }
  
  protected function writeOutput(value : int) : boolean {
    return outputAction(value)
  }
  
  protected function readInput() : Integer {
    return inputAction()
  }
  
  function readOutput() : Integer {
    if(output.HasElements) {
      var value = output.remove()
      if(waitingForOutput) {
        waitingForOutput = false
        run() // ?????????
      }
      return value
    } else return null
  }
  
  function writeInput(value : int) {
    input.add(value)
    if(waitingForInput) {
      waitingForInput = false
      run() // ????
    }
  }
  
  function load(source : File) {
    var data = source.read().split(",").map(\text -> Integer.parseInt(text.trim()))
    memory = data
  }
  function load(data : Integer[]) {
    memory = data.copy()
  }
  
  function peek(address : int) : int {
    return memory[address]
  }
  
  function poke(address : int, value : int) {
    memory[address] = value
  }
  
  private function getModes(count : int, instruction : int) : int[] {
    var modes = new int[count]
    instruction /= 100 // skip opcode
    for(i in 0..|count) {
      modes[i] = instruction % 10
      instruction /= 10
      // leading zeroes are implicit
    }
    return modes
  }
  
  private function getParameters(address : int, modes : int[]) : int[] {
    address = address + 1 // skip past the instruction
    var values = new int[modes.length]
    for(i in 0..|modes.length) {
      if(modes[i] == 0) { // position
        values[i] = memory[memory[address+i]]
      } else if(modes[i] == 1) { // immediate
        values[i] = memory[address+i]
      }
    }
    return values
  }
  
  protected function execute() {
    var instruction = memory[PC]
    
    var opcode = instruction % 100
    
    var instructionLength : int
    switch(opcode) {
      case 01: // add
        instructionLength = 4
        var args = getParameters(PC, getModes(2, instruction))
        dprint("add ${args.join(", ")}")
        var A = args[0]
        var B = args[1]
        var X = memory[PC+3]
        var result = A + B
        memory[X] = result
        break
      case 02: // multiply
        instructionLength = 4
        var args = getParameters(PC, getModes(2, instruction))
        dprint("mul ${args.join(", ")}")
        var A = args[0]
        var B = args[1]
        var X = memory[PC+3]
        var result = A * B
        memory[X] = result
        break
      case 03: // read input
        instructionLength = 2
        var A = readInput()
        if(A == null) {
          waitingForInput = true
          instructionLength = 0
          dprint("input not available; suspend")
          break
        }
        var X = memory[PC+1]
        dprint("input (${A}) -> ${X}")
        memory[X] = A
        break
      case 04: // write output
        instructionLength = 2
        var args = getParameters(PC, getModes(1, instruction))
        var A = args[0]
        dprint("output (${A})")
        var writeStatus = writeOutput(A)
        if(not writeStatus) {
          waitingForOutput = true
          instructionLength = 0
          dprint("output not consumed; suspend")
        }
        break
      case 05: // jump if true
        instructionLength = 3
        var args = getParameters(PC, getModes(2, instruction))
        var A = args[0]
        var B = args[1]
        dprint("jump if true ${A} to ${B}")
        if(A != 0) {
          instructionLength = 0
          PC = B
        }
        break
      case 06: // jump if false
        instructionLength = 3
        var args = getParameters(PC, getModes(2, instruction))
        var A = args[0]
        var B = args[1]
        dprint("jump if false ${A} to ${B}")
        if(A == 0) {
          instructionLength = 0
          PC = B
        }
        break
      case 07: // test less than
        instructionLength = 4
        var args = getParameters(PC, getModes(3, instruction))
        var A = args[0]
        var B = args[1]
        var X = memory[PC+3]
        if(A < B) {
          memory[X] = 1
        } else {
          memory[X] = 0
        }
        break
      case 08: // test equals
        instructionLength = 4
        var args = getParameters(PC, getModes(3, instruction))
        var A = args[0]
        var B = args[1]
        var X = memory[PC+3]
        if(A == B) {
          memory[X] = 1
        } else {
          memory[X] = 0
        }
        break
      
      case 99:
        instructionLength = 1
        halt = true
        dprint("hammertime")
        break
      
      default: // unknown opcode
        output.add(-1)
        halt = true
    }
    PC += instructionLength
    dprint(memory.join(", "))
  }

  function reset() {
    PC = 0
    halt = false
    waitingForInput = false
    input = {}
    output = {}
    dprint("initial ${memory.join(", ")}")
  }
  
  function run() {
    dprint("input [${input.join(", ")}]")
    while(not halt and not waitingForInput and not waitingForOutput) {
      execute()
    }
    dprint("output [${output.join(", ")}]")
  }
}
