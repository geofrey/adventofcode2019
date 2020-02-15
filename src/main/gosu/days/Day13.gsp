uses scratch.intcode.IntcodeComputer
uses scratch.SpaceImage
uses scratch.RasterCloud

/**
 * Day 13: Care Package
 * 
 * Construct an arcade cabinet powered by an Intcode computer.
 * Display is driven by the controller
 * Output group:
 *   x position
 *   y position (distance from the top of the screen)
 *   screen contents
 *     0 - empty
 *     1 - wall
 *     2 - block
 *     3 - paddle
 *     4 - ball
 */

var game_legend = {
  0 -> " ",
  1 -> "#",
  2 -> "*",
  3 -> "@",
  4 -> "o"
}
var game_legend_names = {
  0 -> "empty",
  1 -> "wall",
  2 -> "block",
  3 -> "paddle",
  4 -> "ball"
}

var arcade_program_data = scratch.Util.getPuzzleInput("Day13-input.txt")
var arcade_program = scratch.Util.csvLongs(arcade_program_data)

static class ArcadeCabinet {
  var computer : IntcodeComputer
  var display : RasterCloud
  var drawingBuffer : java.util.concurrent.BlockingQueue<Long>
  var drawCount : int = 0
  
  private var x : Integer = null
  private var y : Integer = null
  private var color : Integer = null
  private function handleOutput(value : int) {
      if(x == null) {
        x = value
      } else if(y == null) {
        y = value
      } else if(color == null) {
        color = value
        
        display.draw(x, y, color)
        drawCount += 1
        
        x = null
        y = null
        color = null
      }
    }
    
  construct(program : Long[]) {
    computer = new IntcodeComputer()
    drawingBuffer = new java.util.concurrent.ArrayBlockingQueue<Long>(3)
    computer.WriteOutputCallback = \value:long -> {
      if(drawingBuffer.remainingCapacity() > 0) return drawingBuffer.add(value)
      else return false
    }
    computer.WriteOutputCallback = \value: long -> { handleOutput(value as int); return true }
    computer.load(program)
    computer.reset()
    
    display = new RasterCloud()
  }
  
  function run() {
    computer.run()
  }
}

function renderDisplay(cloud : RasterCloud) {
  var categories = cloud.Values.toList().partition(\pixel -> pixel.value)
  for(category in game_legend_names.entrySet().orderBy(\es -> es.Key)) {
    var value = category.Key // um...
    var name = category.Value
    var symbol = game_legend[value]
    var count = categories.containsKey(value) ? categories[value].Count : 0
    print("${name} (${symbol}): ${count}")
  }
  
  print(cloud.render(game_legend))
}

var gameRoom = new ArcadeCabinet(arcade_program)
gameRoom.run()
print("${gameRoom.computer.Clock} computer cycles elapsed")
print("${gameRoom.drawCount} display operations")
renderDisplay(gameRoom.display)
