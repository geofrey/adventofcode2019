package scratch

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
  var debug : boolean as Debug = false
  
  // IO
  var input : LinkedList<Integer> as Input
  var output : LinkedList<Integer> as Output
  
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
        if(input.Empty) {
          halt = true
          waitingForInput = true
          instructionLength = 0
          dprint("halt and wait for input")
          break
        }
        var inputValue = input.remove()
        var X = memory[PC+1]
        dprint("input (${inputValue}) -> ${X}")
        memory[X] = inputValue
        break
      case 04: // write output
        instructionLength = 2
        var args = getParameters(PC, getModes(1, instruction))
        var A = args[0]
        dprint("output (${A})")
        output.add(A)
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
    halt = true
    waitingForInput = false
    input = {}
    output = {}
  }
  
  function run() {
    halt = false
    waitingForInput = false
    dprint("initial ${memory.join(", ")}")
    dprint("input [${input.join(", ")}]")
    while(not halt) {
      execute()
    }
    dprint("output [${output.join(", ")}]")
  }
}
