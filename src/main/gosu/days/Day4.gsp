/**
 * Day 4: Secure Container
 * 
 * - password is six digits
 * - password is between 124075 and 580769 (this is the only 'puzzle input'!)
 * - there are two adjacent identical digits
 * - monotonic nondecreasing; consecutive digits do not get smaller
 * 
 * Challenge: How many possible passwords meet these requirements?
 * 
 * Challenge part 2
 * - the two adjacent identical digits don't count if they are part of a longer run
 * 
 */

var LOWERLIMIT = 124075
var UPPERLIMIT = 580769

function testPassword(password : int) : boolean {
  //print("test ${password}")
  if(password < LOWERLIMIT or password > UPPERLIMIT) return false

  var repeat = false
  var nondecreasing = true

  var right = password % 10 // going from right...
  while(password > 10) {
    password /= 10
    var left = password % 10 // ...to left
    repeat ||= (right == left)
    nondecreasing &&= (left <= right)
//    print("${left}->${right}")
//    print("repeat: ${repeat}")
//    print("nondecreasing: ${nondecreasing}")
    right = left
  }
  return repeat and nondecreasing
}

for(password in {111111, 223450, 123789, 124566, 123444, 111122}) {
  print("test ${password}: ${testPassword(password) ? "PASS" : "FAIL"}")
}

/*
var matches = new ArrayList<Integer>()
var start = System.currentTimeMillis()
for(candidate in LOWERLIMIT..UPPERLIMIT index i) {
  if(testPassword(candidate)) {
    matches.add(candidate)
  }
  //if(i > 100000) break
}
var end = System.currentTimeMillis()
print((end - start) / 1E3)

for(match in matches) {
 print(match)
}

print("")
print("${matches.Count} possible correct passwords found")
*/

/*
Part 1
45670 too high
2150 correct

Part 2

*/