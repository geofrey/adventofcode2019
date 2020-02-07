//IntcodeDisassembler.executeWithArgs({"-p", "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"})

var a = new IntegerPoint(1, 2)
var b = new IntegerPoint(1, 2)

print(".equals(): ${a.equals(b)}")
print("object equality: ${a == b}")
print("reference equality: ${a === b}")


print("")

for(bounds in {{0, 10}, {10, 0}}) {
  var start = bounds[0]
  var end = bounds[1]
  for(range in {start..end, start..|end, start|..end, start|..|end}) {
    print(range.toList())
  }
}