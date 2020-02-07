// first stab at automated disassembly

static class Opcode {
  var code : int
  var name : String
  var size : int
  
  override function toString() : String {
    return name
  }
}

static var opcodes : Map<Integer, Opcode> = {
   01 -> new Opcode() {:code=01, :name="add", :size=4}
  ,02 -> new Opcode() {:code=02, :name="mul", :size=4}
  ,03 -> new Opcode() {:code=03, :name="in", :size=2}
  ,04 -> new Opcode() {:code=04, :name="out", :size=2}
  ,05 -> new Opcode() {:code=05, :name="jt", :size=3}
  ,06 -> new Opcode() {:code=06, :name="jf", :size=3}
  ,07 -> new Opcode() {:code=07, :name="tlt", :size=4}
  ,08 -> new Opcode() {:code=08, :name="te", :size=4}
  ,09 -> new Opcode() {:code=09, :name="arb", :size=2}
  
  ,99 -> new Opcode() {:code=99, :name="hlt", :size=1}
  
  /*
  ,98 -> new Opcode() {:code=98, :name="nop", :size=1}
  ,97 -> new Opcode() {:code=97, :name="srb", :size=2}
  */
}

static class Instruction {
  var data : Long[]
  var location : int
  var value : long
  var _opcode : Opcode
  
  construct(program : Long[], offset : int) {
    data = program
    location = offset
    value = data[location]
  }
  
  property get Opcode() : Opcode {
    if(_opcode == null) {
      var code = (value % 100) as int
      if(opcodes.containsKey(code)) {
        _opcode = opcodes.get((value % 100) as int)
      }
    }
    return _opcode
  }
  
  property get ParameterValues() : long[] {
    var parameters = new long[Opcode.size]
    for(i in 0..|Opcode.size-1) parameters[i] = data[location+i+1]
    return parameters
  }
  
  property get ParameterModes() : int[] {
    return IntcodeComputer.getModes(value, Opcode.size - 1)
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
        String.format("[%05d] %s %s", {value, _opcode.name, (0..|Opcode.size-1).map(\i -> modesForDisplay[modes[i]](args[i])).join(" ")})
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
        if((opcode.name == "jt") or (opcode.name == "jf")) {
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
    
        if(opcode.name == "hlt") {
          break
        }
    
        offset += opcode.size
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
    offset += next.Opcode != null ? next.Opcode.size : 1
  }
};

print(buffer)

