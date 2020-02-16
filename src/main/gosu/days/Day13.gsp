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

static class ArcadeCabinet {
  var computer : IntcodeComputer
  var score : Long
  var display : RasterCloud
  var drawCount : int = 0
  
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
          sensePaddle(input_x, input_y)
        }
        if(value == 4) {
          senseBall(input_x, input_y)
        }
      
        input_x = null
        input_y = null
        input_color = null
      }
    }
    
    return true
  }
  
  var paddle_x : int
  function sensePaddle(x : int, y : int) {
    paddle_x = x
    print("paddle ${paddle_x}")
  }
  var ball_x : int
  function senseBall(x : int, y : int) {
    ball_x = x
    print("ball ${ball_x}")
    
    // crappy AI
         if(ball_x < paddle_x) move(L)
    else if(ball_x > paddle_x) move(R)
    else                       move(null)
    
    if(y == 20) {
      renderDisplay()
      Thread.sleep(500)
    }
  }
  
  private var joystick : Direction = null
  function move(stick : Direction) {
    switch(stick) {
      case L:
      case R:
      case null:
        joystick = stick
        break
      default:
        throw new IllegalArgumentException("can't move that way (${stick})")
    }
  }
  private function provideInput() : Long {
    switch(joystick) {
      case L:  return -1
      case R:  return  1
      default: return  0
    }
  }
  
  construct(program : Long[]) {
    computer = new IntcodeComputer()
    computer.load(program)
    computer.reset()
    // don't set up auto-input until after reset() because reset() tries to flush input
    computer.ReadInputCallback = \-> provideInput()
    computer.WriteOutputCallback = \value:long -> handleOutput(value as int)

    display = new RasterCloud()
  }
  
  function insertQuarters() {
    computer.poke(0, 2)
  }
  
  function run() {
    computer.run()
  }
  
  function renderDisplay() {
    print("\tscore: ${score}")
    print(display.render(game_legend))
    print("(${display.Count} screen tiles)")
  }
}

var gameRoom = new ArcadeCabinet(arcade_program)
gameRoom.insertQuarters()
//gameRoom.computer.writeInput(-1) // why are we ending so soon?
gameRoom.run()
print("\n\tGAME OVER\n")
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