// first stab at automated disassembly

static class Instruction {
  var data : Long[]
  var location : int
  var value : long
  var _opcode : Intcode
  
  construct(program : Long[], offset : int) {
    data = program
    location = offset
    value = data[location]
  }
  
  property get Opcode() : Intcode {
    if(_opcode == null) {
      _opcode = Intcode.Intcodes.getOrDefault((value % 100) as int, null)
    }
    return _opcode
  }
  
  property get ParameterValues() : long[] {
    var parameters = new long[Opcode.instructionLength]
    for(i in 0..|Opcode.instructionLength-1) parameters[i] = data[location+i+1]
    return parameters
  }
  
  private function getModes(opcode : Intcode) : Integer[] {
    var flags = value / 100
    var modes = new ArrayList<Integer>()
    while(flags > 0) {
      var mode = (flags % 10) as int
      modes.add(mode)
      flags /= 10
    }
    return modes.toTypedArray()
  }
  
  property get ParameterModes() : Integer[] {
    return getModes(Opcode)
  }
  
  protected var modesForDisplay : Map<Integer,block(instruction:long):String> = {
    0 -> \l -> "@${l}", // positional, a.k.a. simple indirect
    1 -> \l -> l as String, // immediate
    2 -> \l -> "+${l}"  // relative - positional plus global offset
  }
  
  override function toString() : String {
    if(Opcode == null) {
      return value as String
    } else {
      var args = ParameterValues
      var modes = ParameterModes
      return
        String.format("[%05d] %s %s", {value, _opcode.symbol, (0..|Opcode.instructionLength-1).map(\i -> modesForDisplay[modes[i]](args[i])).join(" ")})
        //"[${value}] ${_opcode.name} ${modesForDisplay()}"
        //"${_opcode.name} ${modesForDisplay()}"
    }
  }
}

var memory : Long[]
;{
  var args = gw.lang.Gosu.RawArgs
  if(args == null or args.Empty) {
    print("Run with -f $filename or -p $program or -i to read stdin.")
    return
  }
  
  var scanner : Scanner
  for(arg in args index i) {
    if(arg == "-f") {
      if(i+1 == args.Count) {
        print("'-f' but no file name")
        return
      }
      scanner = new Scanner(new java.io.FileInputStream(args[i+1]))
      break
    }
    if(arg == "-i") {
      scanner = new Scanner(System.in).useDelimiter("[\\s,]")
      break
    }
    if(arg == "-p") {
      scanner = new Scanner(args.subList(i+1, args.Count).join(" ")) // joining up just to pick it apart again...
    }
  }
  scanner.useDelimiter("[\\s,]")
  var memoryBuffer = new LinkedList<Long>()
  while(scanner.hasNextLong()) memoryBuffer.add(scanner.nextLong())
  memory = memoryBuffer.toTypedArray()
};

var a_program = new ArrayList<Instruction>()
memory.eachWithIndex(\data, i -> a_program.add(new Instruction(memory, i)))

var entryPoints : Set<Integer> = {0} // gotta start somewhere
var entryPointsSeen = new HashSet<Integer>()
;{
  while(entryPoints.HasElements) {
    //print("entry points ${entryPoints}")
    var offset = entryPoints.first()
    entryPoints.remove(offset)
    entryPointsSeen.add(offset)
    while(offset < a_program.Count) {
      var opcode = a_program[offset].Opcode
      if(opcode != null) {
        // locations jumped to must be (should be) the start of an executable section - add these to the pool
        if((opcode.symbol == "jt") or (opcode.symbol == "jf")) {
          var modes = a_program[offset].ParameterModes
          if(modes[1] == 0) { // positional jump // WARNING - may be inaccurate for self-modifying code
            //print("${offset}: ${a_program[offset]} add entry point ${a_program[a_program[offset+2].value as int].value}")
            var entryPoint = a_program[offset+2].value as int
            if(not entryPointsSeen.contains(entryPoint)) entryPoints.add(entryPoint)
          } else if(modes[1] == 1) { // immediate jump
            //print("${offset}: ${a_program[offset]} add entry point ${a_program[offset+2].value}")
            var entryPoint = a_program[offset+2].value as int
            if(not entryPointsSeen.contains(entryPoint)) entryPoints.add(entryPoint)
          }
          // can't evaluate a relative jump without tracing the program
        }
    
        if(opcode.symbol == "hlt") {
          break
        }
    
        offset += opcode.instructionLength
      } else {
        offset += 1
      }
    }
  }
};

var buffer = new StringBuilder()

;{
  var offset = 0
  while(offset < a_program.Count) {
    buffer.append(String.format("%04d: ", {offset}))
    var next = a_program[offset]
    buffer.append(next.toString())
    buffer.append(",")
    buffer.append("\n")
    offset += next.Opcode != null ? next.Opcode.instructionLength : 1
  }
};

print(buffer)

