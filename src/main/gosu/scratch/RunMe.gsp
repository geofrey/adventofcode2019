for(sample in {
  {},
  {"one"},
  {"two", "two"},
  {"one", "two", "two"},
  {"5", "5", "5", "5"},
  {"5", "5", "5", "apple", "5", "5"}
}) {
  print(sample)
  print(new RunLengthEncoder(sample.iterator()).toList())
  print("")
}

print("")
var sequence = {"1"}
print("start with: ${sequence}")
for(n in 1..15) {
  var nextSequence = new ArrayList<String>()
  var encoded = new RunLengthEncoder(sequence.iterator()).toList()
  print("${sequence} -> ${encoded}")
  for(run in encoded) {
    nextSequence.add(run.Second as String)
    nextSequence.add(run.First)
  }
  sequence = nextSequence
}
print(sequence)

