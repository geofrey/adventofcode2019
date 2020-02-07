uses scratch.IntegerPoint3
uses java.util.regex.Pattern
uses scratch.Util

/**
 * Day 12: N-Body Problem
 * 
 * Really REALLY simplified physics
 * 
 * Movement
 * - every moon has the same mass. Or, mass doesn't affect gravitation
 * - every pair of moons affects the velocity of both moons
 *   along each axis (x, y, z), add or subtract 1 velocity to accelerate the moons toward each other
 *   i.e. if moon A is lower on the x-axis than moon B then A's x velocity gets += 1 and B's x velocity gets += -1
 * - each time step, every moon moves according to its updated velocity vector
 * 
 * Energy
 * - potential energy is the sum of the absolute values of a body's coordinates
 * - kinetic energy is the sum of the absolute values of a body's velocity components
 * - total energy is the product(!) of a body's potential and kinetic energies
 * 
 * Part 1:
 * What is the total energy of the entire scanned planetary system (puzzle input) after simulating for 1000 steps?
 * 
 */

// this one's short
var puzzleInput = "<x=-13, y=-13, z=-13>\
<x=5, y=-8, z=3>\
<x=-6, y=-10, z=-3>\
<x=0, y=5, z=-5>\
"

static class HeavenlyBody {
  var position : IntegerPoint3
  var velocity : IntegerPoint3
  
  construct(xCoord : int, yCoord : int, zCoord : int) {
    position = new IntegerPoint3(xCoord, yCoord, zCoord)
    velocity = new IntegerPoint3(0, 0, 0)
  }
  
  private static var bodyDataPattern = Pattern.compile("<\\s*x\\s*=\\s*(-?\\d+)\\s*,\\s+y\\s*=\\s*(-?\\d+)\\s*,\\s+z\\s*=\\s*(-?\\d+)\\s*>")
  static function load(data : String) : HeavenlyBody {
    var matcher = bodyDataPattern.matcher(data)
    matcher.find()
    var x = Integer.parseInt(matcher.group(1))
    var y = Integer.parseInt(matcher.group(2))
    var z = Integer.parseInt(matcher.group(3))
    return new HeavenlyBody(x, y, z)
  }
  
  static function energy(point : IntegerPoint3) : int {
    return Math.abs(point.x) + Math.abs(point.y) + Math.abs(point.z)
  }
  property get PotentialEnergy() : int {
    return energy(position)
  }
  
  property get KineticEnergy() : int {
    return energy(velocity)
  }
  
  property get TotalEnergy() : int {
    return PotentialEnergy * KineticEnergy
  }
  
  static function accelerateTogether(one : HeavenlyBody, other : HeavenlyBody) {
    var inOrder : boolean
    var up : HeavenlyBody
    var down : HeavenlyBody
    
    if(one.position.x != other.position.x) {
      inOrder = one.position.x < other.position.x
      down = inOrder ? one : other
      up = inOrder ? other : one
      down.velocity.x += +1
      up.velocity.x += -1
    }
    
    if(one.position.y != other.position.y) {
      inOrder = one.position.y < other.position.y
      down = inOrder ? one : other
      up = inOrder ? other : one
      down.velocity.y += +1
      up.velocity.y += -1
    }
    
    if(one.position.z != other.position.z) {
      inOrder = one.position.z < other.position.z
      down = inOrder ? one : other
      up = inOrder ? other : one
      down.velocity.z += +1
      up.velocity.z += -1
    }
  }
  
  function move() {
    position.x += velocity.x
    position.y += velocity.y
    position.z += velocity.z
  }
  
  override function toString() : String {
    return "pos=${position}, vel=${velocity}"
  }
}

static class PlanetarySystem {
  var bodies : List<HeavenlyBody>
  
  construct(heavenlyBodies : List<HeavenlyBody>) {
    bodies = heavenlyBodies
  }
  
  static function load(data : String) : PlanetarySystem {
    var bodies = new ArrayList<HeavenlyBody>()
    for(line in new Scanner(data).useDelimiter("\n")) {
      bodies.add(HeavenlyBody.load(line))
    }
    return new PlanetarySystem(bodies)
  }
  
  property get TotalEnergy() : int {
    return bodies.map(\body -> body.TotalEnergy).sum()
  }
  
  function timeStep() {
    for(pair in Util.cartesianProduct(bodies, bodies, false)) {
      if(pair.First == pair.Second) continue
      
      HeavenlyBody.accelerateTogether(pair.First, pair.Second)
    }
    for(body in bodies) {
      body.move()
    }
  }
  
  override function toString() : String {
    return bodies.join("\n")
  }
}

function run(planetarySystem : PlanetarySystem, limit : int) {
  print("after 0 steps:")
  print(planetarySystem)
  for(time in 1..limit) {
    planetarySystem.timeStep()
//    print("after ${time} steps:")
//    print(planetarySystem)
  }
  print("after ${limit} steps:")
  print(planetarySystem)
  print("total energy: ${planetarySystem.TotalEnergy}")
  print("")
}

var system : PlanetarySystem

system = PlanetarySystem.load(
"<x=0, y=0, z=0>\
<x=10, y=0, z=0>"
)
run(system, 1)

system = PlanetarySystem.load(
"<x=0, y=0, z=0>\
<x=0, y=10, z=0>"
)
run(system, 1)

system = PlanetarySystem.load(
"<x=0, y=0, z=0>\
<x=0, y=0, z=10>"
)
run(system, 1)

system = PlanetarySystem.load(
"<x=-1, y=0, z=2>\
<x=2, y=-10, z=-7>\
<x=4, y=-8, z=8>\
<x=3, y=5, z=-1>\
"
)
run(system, 10)

system = PlanetarySystem.load(
"<x=-8, y=-10, z=0>\
<x=5, y=5, z=10>\
<x=2, y=-7, z=3>\
<x=9, y=-8, z=-3>\
"
)
run(system, 100)

///

system = PlanetarySystem.load(puzzleInput)
run(system, 1000)
