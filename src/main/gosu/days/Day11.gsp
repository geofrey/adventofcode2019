/**
 * Day 11: Space Police
 * 
 * The Space Police demand a registration number be painted on the hull.
 * Use the (puzzle input) provided Intcode program to drive an Emergency Hull-Painting Robot to accomplish the task.
 * 
 * The EHRP control program reads inputs corresponding to the color currently painted on its location on the hull: black -> 0, white -> 1
 * Outputs are
 *   a) the color the robot should paint here: 0 -> black, 1 -> white
 *   b) a movement command: 0 -> turn left, 1 -> turn right
 * After each turn, the robot moves forward one hull panel.
 * 
 * Movements consist of turning 90 degrees to the left
 */

uses scratch.intcode.IntcodeComputer
uses scratch.IntegerPoint
uses scratch.Direction
uses scratch.Util
uses scratch.SpaceImage
uses scratch.RasterPoint

static class HullPanel extends RasterPoint {
  
  construct(xCoord : int, yCoord : int) {
    super(xCoord, yCoord)
    value = null
  }
  
  construct(other : RasterPoint) {
    super(other)
  }
    // this might not belong here
  function step(direction : Direction) : HullPanel {
    var stepped : HullPanel
    switch(direction) {
      case U:
        stepped = new HullPanel(x, y+1)
        break
      case L:
       stepped = new HullPanel(x-1, y)
       break
      case R:
        stepped = new HullPanel(x+1, y)
        break
      case D:
        stepped = new HullPanel(x, y-1)
        break
      case null:
        return this
      default:
        throw new IllegalStateException("what direction even is ${direction}??")
    }
    stepped.value = value
    return stepped
  }
  
  override function toString() : String {
    return "(${x}, ${y})[${value}]"
  }
}

abstract static class AbstractHullPaintingRobot {
  var computer : IntcodeComputer
  var position : HullPanel
  var orientation : Direction
  
  construct(program : Long[]) {
    computer = new IntcodeComputer()
    computer.load(program)
    computer.reset()
  }
  
  function run(limit : Integer = null) {
    computer.run()
    var iteration = 0
    while(not computer.Halt and (limit == null or iteration < limit)) {
      computer.writeInput(readColor())
      
      var toPaint = computer.readOutput()
      paint(toPaint as int)
      
      var movement = computer.readOutput()
      move(movement as int)
      
      computer.run()
      iteration += 1
    }
  }
  
  abstract function readColor() : long;
  abstract function paint(color : long);
  abstract function move(instruction : long);
}

static class HullPaintingRobot extends AbstractHullPaintingRobot {
  var paintedPanels : Map<Integer, HullPanel>
  
  construct(program : Long[]) {
    super(program)
    paintedPanels = new HashMap<Integer, HullPanel>()
    position = new HullPanel(0, 0)
    
    // part 2: the robot's control program expects to start on a white panel
    position.value = 1
    paintedPanels.put(position.hashCode(), position)
    
    orientation = U
  }
  
  override function readColor() : long {
    if(paintedPanels.containsKey(position.hashCode())) {
      return paintedPanels.get(position.hashCode()).value
    } else {
      return 0
    }
  }
  
  override function paint(color : long) {
    if(paintedPanels.containsKey(position.hashCode())) {
      position = paintedPanels.get(position.hashCode()) // maybe no-op
    } else {
      paintedPanels.put(position.hashCode(), position)
    }
    position.value = color as int
  }
  
  override function move(instruction : long) {
    switch(instruction) {
      case 0:
        orientation = orientation.pred
        break
      case 1:
        orientation = orientation.succ
        break
      default:
        throw new IllegalArgumentException("${instruction} is neither left nor right")
    }
    position = position.step(orientation)
  }
}

function findBounds(points : Collection<IntegerPoint>) : Map<Direction, Integer> {
  var top = Integer.MIN_VALUE
  var bottom = Integer.MAX_VALUE
  var left = Integer.MAX_VALUE
  var right = Integer.MIN_VALUE
  
  for(point in points) {
    if(point.x < left) left = point.x
    if(right < point.x) right = point.x
    if(point.y < bottom) bottom = point.y
    if(top < point.y) top = point.y
  }
  
  return {U -> top, D -> bottom, L -> left, R -> right}
}
var paintingProgram =
  Util.csvLongs(Util.getPuzzleInput("Day11-input.txt"))
  //Util.csvLongs(new java.io.File("/Users/user2017/Desktop/Projects/adventofcode2019/src/main/gosu/days/Day11-input.txt").read())
var testRun = new HullPaintingRobot(paintingProgram)
//testRun.run(8000)
//testRun.computer.Debug = true
testRun.run()

print("${testRun.paintedPanels.Count} hull panels were harmed during the making of this film")

// 10521 too high

var bounds = findBounds(testRun.paintedPanels.Values)
print(bounds)
var width = bounds[R] - bounds[L] + 1
var height = bounds[U] - bounds[D] + 1
print("hull dimensions: ${width} x ${height} (${width * height} panels)")

var hull = SpaceImage.blankImage(width, height, 2)
for(panel in testRun.paintedPanels.Values) {
  hull.data[0][panel.x - bounds[L]][panel.y - bounds[D]] = panel.value as int
}

print(hull.render_upsideDown())

/*
// simple check that coordinate hashes are unique
var hashes = new HashSet<Integer>()
var iRange = -5..5
var jRange = -5..5
var area = iRange.Count * jRange.Count
for(i in iRange) {
  for(j in jRange) {
    var panel = new HullPanel(i,j)
    hashes.add(panel.hashCode())
    print("${panel} -> ${panel.hashCode()}")
  }
}
print("${hashes.Count} ${hashes.Count == area ? "==" : "!="} ${area}")

// simple check that coordinate hashes are consistent
print(new HullPanel(2, 3).hashCode())
print(new HullPanel(2, 3).hashCode())
print(new HullPanel(2, 3).hashCode())
print(new HullPanel(2, 3).hashCode())
print(new HullPanel(2, 3).hashCode())
*/

// it was upside down due to Space Image Format
// JHARBGCU