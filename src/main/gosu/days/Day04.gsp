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
  if(password < LOWERLIMIT or password > UPPERLIMIT) {
    //print("out of range")
    return false
  }

  var repeat = false
  var runLength = 1
  var nondecreasing = true

  var right = password % 10 // going from right...
  while(password > 10) {
    password /= 10
    var left = password % 10 // ...to left
    
    if(right == left) {
      runLength += 1
    } else {
      if(runLength == 2) { // run stopped after two places
        repeat = true
        //print("${left}->${right}, run of 2")
      }
      runLength = 1
    }
    if(not (right >= left)) {
      nondecreasing = false
      //print("${left}->${right}, decreasing digits")
    }
    right = left
  }
  
  if(runLength == 2) { // check again
    repeat = true
    //print("first two places, run of two")
  }
  
  return repeat and nondecreasing
}

var samples = {
  111111 -> false,
  223450 -> false,
  123789 -> false, // out of range
  124566 -> true,
  123444 -> false,
  111122 -> false, // out of range
  333344 -> true
}

var testsOkay = true
for(password in samples.Keys) {
  var expected = samples.get(password)
  var actual = testPassword(password)
  var pass = actual == expected
  print("test ${password}: ${actual ? "valid" : "invalid"} - ${pass ? "PASS" : "FAIL"}")
  testsOkay &&= pass
}

if(testsOkay) { // get on to the real thing
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

  //for(match in matches) {
  // print(match)
  //}

  print("")
  print("${matches.Count} possible correct passwords found")
}

/*
Part 1
45670 too high
2150 correct

Part 2
1462 correct
*/