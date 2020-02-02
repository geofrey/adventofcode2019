package scratch
uses java.io.File

class IntcodeComputer {
  function dprint(msg : String) {
    if(debug) print(msg)
  }
  
  //static var MEMORYSIZE = 4096
  static var MEMORYSIZE = 2000
  // basics
  var memory : long[]
  var PC : int
  var relativeBase : int
  var clock : long as Clock // could be going a long time
  
  // flags
  var halt : boolean as Halt
  var waitingForInput : boolean as WaitingForInput
  var waitingForOutput : boolean as WaitingForOutput
  var debug : boolean as Debug = false
  
  // IO
  var input : LinkedList<Long>
  var output : LinkedList<Long>
  var outputAction : block(value:long) : boolean as OutputCallback
  var inputAction : block() : Long as InputCallback
  
  construct() {
    init()
    memory = new long[MEMORYSIZE]
  }
  
  final function init() {
    initDefaultIO() // this is just a total hack, isn't it
  }
  
  function initDefaultIO() {
    input = new LinkedList<Long>()
    output = new LinkedList<Long>()
    outputAction = \value -> output.add(value)
    inputAction = \-> input.HasElements ? input.remove() : null
  }
    
  function reset() {
    PC = 0
    clock = 0
    relativeBase = 0
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
  
  function load(source : File) {
    load(source.read())
  }
  function load(listing : String) {
    load(listing.split(",").map(\text -> Long.parseLong(text.trim())))
  }
  function load(data : Long[]) {
    for(i in 0..|data.length) memory[i] = data[i]
  }
  
  function peek(address : int) : long {
    return memory[address]
  }
  
  function poke(address : int, value : long) {
    memory[address] = value
  }
  
  protected function writeOutput(value : long) : boolean {
    return outputAction(value)
  }
  
  protected function readInput() : Long {
    return inputAction()
  }
  
  function readOutput() : Long {
    if(output.HasElements) {
      var value = output.remove()
      if(waitingForOutput) {
        waitingForOutput = false
        run() // ?????????
      }
      return value
    } else return null
  }
  
  function writeInput(value : long) {
    input.add(value)
    if(waitingForInput) {
      waitingForInput = false
      run() // ????
    }
  }
  
  function dumpOutput() : List<Long> {
    var contents = new ArrayList<Long>()
    var value = readOutput()
    while(value != null) {
      contents.add(value)
      value = readOutput()
    }
    return contents
  }
  
  static function getModes(instruction : long, count : int) : int[] {
    var modes = new int[count]
    instruction /= 100 // skip opcode
    for(i in 0..|count) {
      modes[i] = (instruction % 10) as int
      instruction /= 10
      // leading zeroes are implicit
    }
    return modes
  }
  
  private function getParameters(address : int, count : int) : long[] {
    var parameters = new long[count]
    for(i in 0..|count) {
      parameters[i] = memory[address + 1 + i]
      dprint("load parameter ${address}[${i}+1] : ${parameters[i]}")
    }
    return parameters
  }
  
  private static var modeName : String[] = {"positional", "immediate", "relative"}
  
  protected function fetch(arg : long, mode : int) : long {
    var value : long
    switch(mode) {
      case 0:
        value = memory[arg as int]
        dprint("fetch ${arg} ${modeName[mode]} : ${value}")
        break
      case 1:
        value = arg
        dprint("fetch ${value} ${modeName[mode]}")
        break
      case 2:
        value = memory[arg as int + relativeBase]
        dprint("fetch ${arg} ${modeName[mode]} ${relativeBase} : ${value}")
        break
      default:
        // what have you done
        throw new IllegalArgumentException("fetch mode ${mode}")
    }
    return value
  }
  
  protected function store(address : int, mode : int, value : long) {
    var target : int
    switch(mode) {
      case 0:
        target = address
        break
      // "parameters that an instruction writes to will never be in immediate mode"
      case 2:
        target = address + relativeBase
        break
      default:
        throw new IllegalArgumentException("store mode ${mode}")
    }
    dprint("store ${value} -> ${address} ${modeName[mode]} -> ${target}")
    memory[target] = value
  }
  
  function execute() {
    clock += 1
    
    var instruction = memory[PC]
    dprint("execute ${instruction}")
    var opcode = instruction % 100
    
    var instructionLength : int
    switch(opcode) {
      case 01: // add
        instructionLength = 4
        var args = getParameters(PC, 3)
        var modes = getModes(instruction, 3)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("add ${A} + ${B}")
        //var X = args[2] as int
        var result = A + B
        store(args[2] as int, modes[2], result)
        break
      case 02: // multiply
        instructionLength = 4
        var args = getParameters(PC, 3)
        var modes = getModes(instruction, 3)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("mul ${A} * ${B}")
        var result = A * B
        store(args[2] as int, modes[2], result)
        break
      case 03: // read input
        instructionLength = 2
        var args = getParameters(PC, 1)
        var modes = getModes(instruction, 1)
        dprint("(read input)")
        var A = readInput()
        if(A == null) {
          waitingForInput = true
          instructionLength = 0
          dprint("input not available; suspend")
          break
        }
        dprint("input ${A}")
        store(args[0] as int, modes[0], A)
        break
      case 04: // write output
        instructionLength = 2
        var args = getParameters(PC, 1)
        var modes = getModes(instruction, 1)
        var A = fetch(args[0], modes[0])
        dprint("output ${A}")
        var writeStatus = writeOutput(A)
        if(not writeStatus) {
          waitingForOutput = true
          instructionLength = 0
          dprint("output not consumed; suspend")
        }
        break
      case 05: // jump if true
        instructionLength = 3
        var args = getParameters(PC, 2)
        var modes = getModes(instruction, 2)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("jump if true ${A} to ${B}")
        if(A != 0) {
          instructionLength = 0
          PC = B as int
        }
        break
      case 06: // jump if false
        instructionLength = 3
        var args = getParameters(PC, 2)
        var modes = getModes(instruction, 2)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("jump if false ${A} to ${B}")
        if(A == 0) {
          instructionLength = 0
          PC = B as int
        }
        break
      case 07: // test less than
        instructionLength = 4
        var args = getParameters(PC, 3)
        var modes = getModes(instruction, 3)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("test ${A} < ${B}")
        var C : long
        if(A < B) {
          C = 1
        } else {
          C = 0
        }
        store(args[2] as int, modes[2], C)
        break
      case 08: // test equals
        instructionLength = 4
        var args = getParameters(PC, 3)
        var modes = getModes(instruction, 3)
        var A = fetch(args[0], modes[0])
        var B = fetch(args[1], modes[1])
        dprint("test ${A} = ${B}")
        var C : long
        if(A == B) {
          C = 1
        } else {
          C = 0
        }
        store(args[2] as int, modes[2], C)
        break
      case 09: // adjust relative base
        instructionLength = 2
        var args = getParameters(PC, 1)
        var modes = getModes(instruction, 1)
        var A = fetch(args[0], modes[0])
        var oldBase = relativeBase
        relativeBase += A as int
        dprint("adjust relative base ${oldBase} + ${A} -> ${relativeBase}")
        break
      
      case 99: // halt
        instructionLength = 0
        halt = true
        dprint("hammertime")
        break
      
      // NONSTANDARD FEATURES
      // stuff that felt like it ought to be there
      case 98: // no-op
        instructionLength = 1
        dprint("nope")
        break
      case 97: // set relative base
        instructionLength = 2
        var args = getParameters(PC, 1)
        var modes = getModes(instruction, 1)
        var A = fetch(args[0], modes[0])
        dprint("set relative base to ${A}")
        relativeBase = A as int
        break
      
      default: // unknown opcode
        dprint("illegal instruction ${instruction}")
        halt = true
        throw new IllegalStateException("illegal instruction ${instruction}")
    }
    PC += instructionLength
    dprint(memory.join(", "))
  }

}
