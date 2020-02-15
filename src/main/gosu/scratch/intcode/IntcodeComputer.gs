package scratch.intcode
uses java.io.File

class IntcodeComputer {
  function dprint(msg : String) {
    if(debug) print(msg)
  }
  
  static var MEMORYSIZE = 4000
  
  // basics
  var memory : long[]
  protected var PC : int
  protected var relativeBase : int
  protected var instructionLength : int
  // internals
  var intcode : Intcode
  var modes : int[] = new int[3] // change these if we ever add a really long instruction
  var parameters : long[] = new long[3]
  
  var clock : long as Clock // could be going a long time
  
  // flags
  protected var halt : boolean as Halt
  protected var waitingForInput : boolean as WaitingForInput
  protected var waitingForOutput : boolean as WaitingForOutput
  var debug : boolean as Debug = false
  
  // IO
  var writeOutputAction : block(value:long):boolean as WriteOutputCallback
  var readOutputAction :  block():Long              as ReadOutputCallback
  var readInputAction :   block():Long              as ReadInputCallback
  var writeInputAction :  block(value:long):boolean as WriteInputCallback
  
  static var intcodes = Intcode.Intcodes
  
  construct() {
    init()
    memory = new long[MEMORYSIZE]
  }
  
  final function init() {
    initDefaultIO() // this is just a total hack, isn't it
  }
  
  function initDefaultIO() {
    var output = new LinkedList<Long>()
    writeOutputAction = \value -> output.add(value)
    readOutputAction = \-> {
      if(output.HasElements) {
        return output.remove()
      } else return null
    }

    var input = new LinkedList<Long>()
    writeInputAction = \value:long-> {
      if(not input.add(value)) return false
      return true
    }
    readInputAction = \ -> {
      if(input.HasElements) return input.remove()
      else return null
    }
    
  }
    
  function reset() {
    PC = 0
    clock = 0
    relativeBase = 0
    halt = false
    while(readInputAction() != null); // burn any remaining IO
    while(readOutputAction() != null);
    waitingForInput = false
    dprint("initial ${memory.join(", ")}")
  }
  
  function run() {
    //dprint("input [${input.join(", ")}]")
    while(not halt and not waitingForInput and not waitingForOutput) {
      step()
    }
    //dprint("output [${output.join(", ")}]")
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
  
  protected function readInput() : Long {
    return readInputAction()
  }
  
  function readOutput() : Long {
    var value = readOutputAction()
    if(waitingForOutput) waitingForOutput = false
    run()
    return value
  }
  
  function writeInput(value : long) : boolean {
    if(not writeInputAction(value)) return false
    if(waitingForInput) {
      waitingForInput = false
      run() // ????
    }
    return true
  }
  
  protected function writeOutput(value : long) : boolean {
    return writeOutputAction(value)
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
  
  private function decodeInstruction() : boolean {
    var instruction = memory[PC]
    var opcode = (instruction % 100) as int
    if(intcodes.containsKey(opcode)) {
      intcode = intcodes.get(opcode)
      return true
    } else {
      dprint("illegal instruction ${instruction}")
      halt = true
      return false
    }
  }
  
  private function decodeModes() {
    var instruction = memory[PC]
    instruction /= 100 // skip opcode
    for(i in 0..|modes.length) {
      modes[i] = (instruction % 10) as int
      instruction /= 10
      // leading zeroes are implicit
    }
  }
  
  private function fetchParameters() {
    for(i in 0..|parameters.length) {
      parameters[i] = memory[PC + 1 + i]
      dprint("load parameter ${PC}[${i}+1] : ${parameters[i]}")
    }
  }
  
  private static var modeName : String[] = {"positional", "immediate", "relative"}
  
  protected function fetch(parameter : int) : long {
    var arg = parameters[parameter]
    var mode = modes[parameter]
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
  
  protected function store(parameter : int, value : long) {
    var address = parameters[parameter] as int
    var mode = modes[parameter]
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
  
  function step() {
    clock += 1
    
    if(decodeInstruction()) {
      decodeModes()
      fetchParameters()
      instructionLength = intcode.instructionLength // may be modified by microcode
      intcode.execute(this)
      PC += instructionLength
    }
    
    dprint(memory.join(", "))
  }

}
