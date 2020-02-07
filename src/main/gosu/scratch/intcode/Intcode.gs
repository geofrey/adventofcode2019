package scratch.intcode

class Intcode {
  public var symbol : String
  public var opcode : int
  public var instructionLength : int
  public var execute : block(computer : IntcodeComputer)
  
  /**
   * Advent of Code 2019 said 'your Intcode computer is complete' after implementing
   *   add, mul, hlt, in, out, jt, jf, tlt, te, arb
   * These instructions therefore constitute revision 0 of the Intcode specification.
   * 
   * Additional instructions are
   *   nop, srb
   * In revision 1.
   * 
   * A correct Intcode program written against spec 0 will not behave differently with additional opcodes enabled,
   * since it would not attempt to execute any address with a nonstandard opcode in the first place. Therefore
   * enabling new operations should be (and has been demonstrated) safe with 'official' programs provided in AoC2019 puzzles.
   */
  public var spec : int
  
  private static var allIntcodes : List<Intcode> = {
    new Intcode() { :symbol = "add", :opcode = 1, :instructionLength = 4, :spec = 0, :execute = \ic-> {
      // add
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("add ${A} + ${B}")
      var result = A + B
      ic.store(2, result)
    }},
    new Intcode() { :symbol = "mul", :opcode = 2, :instructionLength = 4, :spec = 0, :execute = \ic -> {
      // multiply
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("mul ${A} * ${B}")
      var result = A * B
      ic.store(2, result)
    }},
    new Intcode() { :symbol = "in", :opcode = 3, :instructionLength = 2, :spec = 0, :execute = \ic -> {
      // read input
      ic.dprint("(read input)")
      var A = ic.readInput()
      if(A == null) {
        ic.waitingForInput = true
        ic.dprint("input not available; suspend")
        ic.instructionLength = 0
        return
      }
      ic.dprint("input ${A}")
      ic.store(0, A)
    }},
    new Intcode() { :symbol = "out", :opcode = 4, :instructionLength = 2, :spec = 0, :execute = \ic -> {
      // write output
      var A = ic.fetch(0)
      ic.dprint("output ${A}")
      var writeStatus = ic.writeOutput(A)
      if(not writeStatus) {
        ic.waitingForOutput = true
        ic.dprint("output not consumed; suspend")
      }
    }},
    new Intcode() { :symbol = "jt", :opcode = 05, :instructionLength = 3, :spec = 0, :execute = \ic -> {
      // jump if true
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("jump if true ${A} to ${B}")
      if(A != 0) {
        ic.instructionLength = 0
        ic.PC = B as int
      }
    }},
    new Intcode() { :symbol = "jf", :opcode = 6, :instructionLength = 3, :spec = 0, :execute = \ic -> {
      // jump if false
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("jump if false ${A} to ${B}")
      if(A == 0) {
        ic.instructionLength = 0
        ic.PC = B as int
      }
    }},
    new Intcode() { :symbol = "tlt", :opcode = 7, :instructionLength = 4, :spec = 0, :execute = \ic -> {
      // test less-than
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("test ${A} < ${B}")
      var C : long
      if(A < B) {
        C = 1
      } else {
        C = 0
      }
      ic.store(2, C)
    }},
    new Intcode() { :symbol = "te", :opcode = 8, :instructionLength = 4, :spec = 0, :execute = \ic -> {
      // test equal
      var A = ic.fetch(0)
      var B = ic.fetch(1)
      ic.dprint("test ${A} = ${B}")
      var C : long
      if(A == B) {
        C = 1
      } else {
        C = 0
      }
      ic.store(2, C)
    }},
    new Intcode() { :symbol = "arb", :opcode = 9, :instructionLength = 2, :spec = 0, :execute = \ic -> {
      // adjust relative base
      var A = ic.fetch(0)
      var oldBase = ic.relativeBase
      ic.relativeBase += A as int
      ic.dprint("adjust relative base ${oldBase} + ${A} -> ${ic.relativeBase}")
    }},
    
    new Intcode() { :symbol = "hlt", :opcode = 99, :instructionLength = 0, :spec = 0, :execute = \ic -> {
      // halt
      ic.halt = true
      ic.dprint("hammertime")
    }},
    
    // NONSTANDARD FEATURES
    // stuff that felt like it ought to be there
    new Intcode() { :symbol = "nop", :opcode = 98, :instructionLength = 1, :spec = 1, :execute = \ic -> {
      // no-op
      ic.dprint("nope")
    }},
    new Intcode() { :symbol = "srb", :opcode = 97, :instructionLength = 2, :spec = 1, :execute = \ic -> {
      // set relative base
      var A = ic.fetch(0)
      ic.dprint("set relative base to ${A}")
      ic.relativeBase = A as int
    }}
  }
  
  private static var _Intcodes : Map<Integer, Intcode> = null
  public static property get Intcodes() : Map<Integer, Intcode> {
    //return allIntcodes.mapToKeyAndValue(\code -> code.opcode as Integer, \code -> code) // "This is an ambiguous function call." wtf
    if(_Intcodes == null) {
      _Intcodes = new HashMap<Integer, Intcode>()
      for(code in allIntcodes) _Intcodes.put(code.opcode, code)
    }
    return _Intcodes
  }
}
