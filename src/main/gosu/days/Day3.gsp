uses java.io.FileInputStream
uses java.util.regex.Pattern
uses gw.util.Pair

/**
 * Day 3: Crossed Wires
 * 
 * Find where wires are crossed inside the fuel management system.
 * 
 * Two wire paths are given in incremental steps, direction+distance. Both wires begin at the center
 * of a grid and can end anywhere.
 * Find the locations where the wires cross on the grid and report the distance from the origin to the
 * nearest crossing (Manhattan distance). Self-crossings do not count.
 */

function manhattanDistance(intersect : Intersection) : int {
  return manhattanDistance(intersect.Location)
}

function manhattanDistance(coord : Pair<Integer, Integer>) : int {
  return manhattanDistance(coord.First, coord.Second)
}

function manhattanDistance(x : int, y : int) : int {
  return Math.abs(x) + Math.abs(y)
}

enum Direction {
  R,
  L,
  U,
  D
}

class Intersection {
  var segment1 : Segment
  var segment2 : Segment
  var time : int
  
  construct(one : Segment, two : Segment) {
    segment1 = one
    segment2 = two
  }
  
  override function toString() : String {
    return "${segment1} X ${segment2} @ ${Location}, t=${TimeSum}"
  }
  
  private property get HV() : Pair<Segment, Segment> {
    var horiz = segment1.Horizontal ? segment1 : segment2
    var vert = segment1.Horizontal ? segment2 : segment1
    return Pair.make(horiz, vert)
  }
  
  property get Location() : Pair<Integer, Integer> {
    var hv = HV
    var horiz = hv.First
    var vert = hv.Second
    return Pair.make(vert.origin.First, horiz.origin.Second)
  }
  
  property get TimeSum() : int {
    var hv = HV
    var horiz = hv.First
    var vert = hv.Second
    
    var htime = horiz.time + Math.abs(horiz.origin.First - vert.origin.First)
    var vtime = vert.time + Math.abs(vert.origin.Second - horiz.origin.Second)
    
    return htime + vtime
  }
}

class Segment {
  var direction : Direction
  var distance : int
  var origin : Pair<Integer, Integer>
  var time : int
  
  construct(text : String) {
    var directions = Direction.values()*.Name.join("")
    var parts = Pattern.compile("(?<=[${directions}])(?=\\p{Digit})").split(text)
    //print("construct: ${parts.join(", ")}")
    direction = Direction.valueOf(parts[0])
    distance = Integer.parseInt(parts[1])
  }
  
  override function toString() : String {
    return "${origin}+${direction}${distance}"
  }
  
  property get Horizontal() : boolean {
    return direction == L or direction == R
  }
  
  function intersect(that : Segment) : Intersection {
    // this and that must have their origins set
    if(this.Horizontal == that.Horizontal) return null
    
    // which is which
    var horiz = this.Horizontal ? this : that
    var vert = this.Horizontal ? that : this
    
    // normalize
    var hmin = horiz.direction == R ? horiz.origin.First : horiz.origin.First - horiz.distance
    var hmax = horiz.direction == R ? horiz.origin.First + horiz.distance : horiz.origin.First
    var vmin = vert.direction == U ? vert.origin.Second : vert.origin.Second - vert.distance
    var vmax = vert.direction == U ? vert.origin.Second + vert.distance : vert.origin.Second
    
    // nevermind the bollocks, here's the geometry
    if(
      hmin < vert.origin.First and vert.origin.First < hmax
      and
      vmin < horiz.origin.Second and horiz.origin.Second < vmax
    ) {
      return new Intersection(vert, horiz)
    }
    
    return null
  }
}

class Path {
  var segments : Segment[]
  
  construct(line : String) {
    segments = line.split(",").map(\text -> new Segment(text.trim()))
    walk()
  }
  
  override function toString() : String {
    return segments.join(", ")
  }
  
  private function walk() {
    //print("commence walking.")
    
    var x = 0
    var y = 0
    var time = 0
    for(segment in segments) {
      segment.origin = Pair.make(x, y)
      segment.time = time
      switch(segment.direction) {
        case R: x += segment.distance; break
        case L: x -= segment.distance; break
        case U: y += segment.distance; break
        case D: y -= segment.distance; break
      }
      time += segment.distance
    }
  }
}


var wire1 : Path
var wire2 : Path

// challenge
var inputLocation = "c:/Users/gsanders/Desktop/Projects/adventofcode2019/src/main/gosu/days/Day3-input.txt"
var lines = new Scanner(new FileInputStream(inputLocation))
wire1 = new Path(lines.next())
wire2 = new Path(lines.next())

//wire1 = new Path("R8,U5,L5,D3"); wire2 = new Path("U7,R6,D4,L4") // example
//wire1 = new Path("R75,D30,R83,U83,L12,D49,R71,U7,L72"); wire2 = new Path("U62,R66,U55,R34,D71,R55,D58,R83") // sample 1
//wire1 = new Path("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"); wire2 = new Path("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") // sample 2

print(wire1)
print(wire2)

var crossings = new ArrayList<Intersection>()
for(s1 in wire1.segments) {
  for(s2 in wire2.segments) {
    var intersection = s1.intersect(s2)
    if(intersection != null) {
      crossings.add(intersection)
    }
  }
}

var shortestDistance = Integer.MAX_VALUE
var bestCrossing : Intersection = null
for(crossing in crossings) {
  var distance = manhattanDistance(crossing)
  if(distance < shortestDistance) {
    shortestDistance = distance
    bestCrossing = crossing
  }
  //print(crossing)
}

print("closest crossing, ${bestCrossing}")

var shortestTime = Integer.MAX_VALUE
bestCrossing = null
for(crossing in crossings) {
  var time = crossing.TimeSum
  if(time < shortestTime) {
    shortestTime = time
    bestCrossing = crossing
  }
}

print("shortest-total-time crossing, ${bestCrossing}")
