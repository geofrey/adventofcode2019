uses java.util.regex.Pattern
uses java.io.File

/**
 * Day 6: Universal Orbit Map
 * 
 * AAA)BBB means "BBB is in orbit around AAA"
 * This is a direct orbit.
 * 
 * If BBB)CCC, then CCC is in an indirect orbit around AAA.
 * 
 * In the system
 * AAA)BBB
 * BBB)CCC
 * there are two direct orbits and one indirect orbit.
 * 
 * Challenge input is a list of direct orbits.
 * 
 * Part One: Calculate the total number of
 * direct and indirect orbits in the map.
 * 
 * Part Two: Calculate the number of orbital transfers needed to move
 * from the object you (YOU) are currently orbiting to the object Santa
 * (SAN) is currently orbiting.
 * 
 */

class Body {
  var name : String
  var parent : Body as Parent
  
  construct(bodyName : String) {
    name = bodyName
  }
  
  function parents() : List<Body> {
    var result = new ArrayList<Body>()
    var currentBody = parent
    while(currentBody != null) {
      result.add(currentBody)
      currentBody = currentBody.parent
    }
    return result
  }
  
  function countOrbits() : int {
    return parents().Count
  }
  
  function commonParent(that : Body) : Body {
    var ourParents = parents()
    var theirParents = that.parents()
    return ourParents.firstWhere(\body -> theirParents.contains(body)) // O(n^2)
  }
  
  override function toString() : String {
    return name
  }
}

class System {
  var bodies : Map<String, Body>
  
  construct(data : String) {
    init(data)
  }
  
  final function init(data : String) {
    bodies = new HashMap<String, Body>()
    var orbitRegex = Pattern.compile("(\\w+)\\)(\\w+)").matcher(data)
    while(orbitRegex.find()) {
      var parent = orbitRegex.group(1)
      var child = orbitRegex.group(2)
      addOrbit(parent, child)
    }
  }
  
  function addOrbit(parent : String, child : String) {
    if(not bodies.containsKey(parent)) {
      bodies.put(parent, new Body(parent))
    }
    if(not bodies.containsKey(child)) {
      bodies.put(child, new Body(child))
    }
    bodies.get(child).Parent = bodies.get(parent)
  }
  
  function countOrbits() : int {
    return bodies.Values.sum(\body -> body.countOrbits())
  }
  
  function countTransfersBetween(objectOne : String, objectTwo : String) : Integer {
    return countTransfersBetween(bodies.get(objectOne), bodies.get(objectTwo))
  }
  function countTransfersBetween(objectOne : Body, objectTwo : Body) : Integer {
    var commonParent = objectOne.commonParent(objectTwo)
    var transfersIn = objectOne.parents().indexOf(commonParent)
    var transfersOut = objectTwo.parents().indexOf(commonParent)
    return transfersIn + transfersOut
  }
  
  override function toString() : String {
    var buffer = new StringBuilder()
    for(body in bodies.Values) buffer.append(body + "\n")
    return buffer.toString()
  }
}

var sampleMap = "COM)B\
B)C\
C)D\
D)E\
E)F\
B)G\
G)H\
D)I\
E)J\
J)K\
K)L\
"
var sampleSystem = new System(sampleMap)
print(sampleSystem)
var testResults = new ArrayList<Boolean>()

var parentsCount = sampleSystem.bodies.get("J").countOrbits()
var parentsTest = parentsCount == 5
print("J has ${parentsCount} orbits - ${parentsTest ? "PASS" : "FAIL"}")
testResults.add(parentsTest)

var sampleCount = sampleSystem.countOrbits()
var orbitTest = sampleCount == 42
print("${sampleCount} sample orbits - ${orbitTest ? "PASS" : "FAIL"}")
testResults.add(orbitTest)

print("(add characters)")
sampleSystem.addOrbit("I", "SAN")
sampleSystem.addOrbit("K", "YOU")
var sampleTransfers = sampleSystem.countTransfersBetween("YOU", "SAN")
var transferTest = sampleTransfers == 4
print("${sampleTransfers} sample transfers to Santa - ${transferTest ? "PASS" : "FAIL"}")
testResults.add(transferTest)

if(testResults.fold(\l,r -> l and r)) {
  print("all tests passed, proceed to challenge")
  
  var inputLocation = "src/main/gosu/days/Day6-input.txt"
  var map = new File(inputLocation).read()
  var system = new System(map)
  print("${system.bodies.Count} bodies in system")
  
  // PART ONE
  var orbits = system.countOrbits()
  print("${orbits} orbits in map")
  
  // PART TWO
  var transfers = system.countTransfersBetween("YOU", "SAN")
  print("${transfers} transfers to Santa")
  
}
