uses scratch.intcode.IntcodeComputer
uses scratch.SpaceImage
uses scratch.RasterCloud
uses scratch.Direction

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

static var game_legend = {
  0 -> " ",
  1 -> "#",
  2 -> "*",
  3 -> "@",
  4 -> "o"
}
static var game_legend_names = {
  0 -> "empty",
  1 -> "wall",
  2 -> "block",
  3 -> "paddle",
  4 -> "ball"
}

var arcade_program_data =
  //scratch.Util.getPuzzleInput("Day13-input.txt")
  new java.io.File("c:/Users/user2017/Desktop/Projects/adventofcode2019/src/main/gosu/days/Day13-input.txt").read()

var arcade_program = scratch.Util.csvLongs(arcade_program_data)

static interface BreakoutPlayer {
  function sensePaddle(x : int)
  function senseBall(x : int)
  function getCommand() : int
}

static class BreakoutRobot implements BreakoutPlayer {
  var paddle_x : Integer
  var ball_x : Integer
  var delta : Integer
  construct() {
    paddle_x = null
    ball_x = null
    delta = null
  }
  override function sensePaddle(x : int) {
    paddle_x = x
    if(ball_x != null) delta = ball_x - paddle_x
    print("paddle at x=${paddle_x}; delta=${delta}")
  }
  override function senseBall(x : int) {
    ball_x = x
    if(paddle_x != null) delta = ball_x - paddle_x
    print("ball at x=${ball_x}; delta=${delta}")
  }
  override function getCommand() : int {
    print("get input: ${paddle_x} --[${delta}]--> ${ball_x}")
    if(delta != null and delta < 0) {
      delta += 1 // assume the paddle moves each time we're asked
      return -1
    }
    if(delta != null and delta > 0) {
      delta -= 1
      return +1
    }
    
    return 0
  }
}

static class ArcadeCabinet {
  var computer : IntcodeComputer
  var score : Long
  var display : RasterCloud
  var drawCount : int = 0
  
  var player : BreakoutPlayer
  
  private var input_x : Integer = null
  private var input_y : Integer = null
  private var input_color : Integer = null
  private function handleOutput(value : int) : boolean {
    if(input_x == null) {
      input_x = value
    } else if(input_y == null) {
      input_y = value
    } else if(input_color == null) {
      if(input_x == -1 and input_y == 0) {
        // update score
        score = value
      } else {
        // draw something
        input_color = value
      
        display.draw(input_x, input_y, input_color)
        drawCount += 1
        
        if(value == 3) {
          player.sensePaddle(input_x)
        }
        if(value == 4) {
          player.senseBall(input_x)
        }
      
        input_x = null
        input_y = null
        input_color = null
      }
    }
    
    return true
  }
  
  construct(program : Long[]) {
    computer = new IntcodeComputer()
    computer.load(program)
    computer.reset()
    
    player = new BreakoutRobot()
    // don't set up auto-input until after reset() because reset() tries to flush input
    
    var inputCount = 0
    var outputCount = 0
    computer.ReadInputCallback = \-> {
      //renderDisplay()
      inputCount += 1
      print("${inputCount} inputs read, t=${computer.Clock}")
      return player.getCommand()
    }
    computer.WriteOutputCallback = \value:long -> {
      outputCount += 1
      //print("${outputCount} outputs written, t=${computer.Clock}") // noisy
      return handleOutput(value as int)
    }

    display = new RasterCloud()
  }
  
  function insertQuarters() {
    computer.poke(0, 2)
  }
  
  function run() {
    computer.run()
    print("execution suspended")
    print("halt ${computer.Halt}")
    print("waiting for input ${computer.WaitingForInput}")
    print("waiting for output ${computer.WaitingForOutput}")
    print("error ${computer.Error}")
  }
  
  function renderDisplay() {
    print("\tscore: ${score}")
    print(display.render(game_legend))
    print("(${display.Count} screen tiles)")
  }
}

var gameRoom = new ArcadeCabinet(arcade_program)
gameRoom.insertQuarters()
//gameRoom.computer.writeInput(1) // why are we ending so soon?

gameRoom.run()
print("\n\tGAME OVER\n")
gameRoom.renderDisplay()

print("${gameRoom.computer.Clock} computer cycles elapsed")
print("${gameRoom.drawCount} display operations")

;{
    var categories = gameRoom.display.Values.toList().partition(\pixel -> pixel.value)
    for(category in game_legend_names.entrySet().orderBy(\es -> es.Key)) {
      var value = category.Key // um...
      var name = category.Value
      var symbol = game_legend[value]
      var count = categories.containsKey(value) ? categories[value].Count : 0
      print("${name} (${symbol}): ${count}")
    }
};