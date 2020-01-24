package scratch

class IntCodeComputer {
  var memory : Integer[]
  var PC : int
  var halt : boolean
  var debug : boolean as Debug = false
  
  function load(data : Integer[]) {
    memory = data.copy()
  }
  
  function peek(address : int) : int {
    return memory[address]
  }
  
  function poke(address : int, value : int) {
    memory[address] = value
  }
  
  function execute() {
    var opcode = memory[PC]

    switch(opcode) {
      case 1:
        var A = memory[PC+1]
        var B = memory[PC+2]
        var X = memory[PC+3]
        var result = memory[A] + memory[B]
        memory[X] = result
        PC += 4
        break
      case 2:
        var A = memory[PC+1]
        var B = memory[PC+2]
        var X = memory[PC+3]
        var result = memory[A] * memory[B]
        memory[X] = result
        PC += 4
        break
      case 99:
        halt = true
        break
    }
  }

  function reset() {
    PC = 0
    halt = true
  }
  
  function run() {
    halt = false
    if(debug) print(memory.join(", "))
    while(not halt) {
      execute()
    }
    if(debug) print(memory.join(", "))
  }
}
