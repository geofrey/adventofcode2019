var p = 223450
while(p > 10) {
  var right = p % 10
  p /= 10
  var left = p % 10
  print("${left}->${right}")
}