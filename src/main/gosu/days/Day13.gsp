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

static interface IBreakoutPlayer {
  function sensePaddle(x : int)
  function senseBall(x : int)
  function getCommand() : int
  
  function beginPlay(game : ArcadeCabinet)
}

static class ArcadeCabinet {
  var computer : IntcodeComputer
  var score : Long
  var display : RasterCloud
  
  var player : IBreakoutPlayer
  
  private var input_x : Integer = null
  private var input_y : Integer = null
  
  private function handleOutput(value : int) : boolean {
    if(input_x == null) {
      input_x = value
    } else if(input_y == null) {
      input_y = value
    } else {
      if(input_x == -1 and input_y == 0) {
        print("update score: ${value}")
        score = value
      } else {
        // draw something
        display.draw(input_x, input_y, value)
        
        if(value == 3) {
          player.sensePaddle(input_x)
        }
        if(value == 4) {
          player.senseBall(input_x)
        }
      }
      
      input_x = null
      input_y = null
    }
    
    return true
  }
  
  var inputCount = 0
  var outputCount = 0
  construct(program : Long[]) {
    computer = new IntcodeComputer()
    computer.load(program)
    display = new RasterCloud()
  }
  
  function insertQuarters() {
    computer.poke(0, 2)
  }
  
  function checkCredit() : long {
    return computer.peek(0)
  }
  
  function run(controller : IBreakoutPlayer) {
    computer.reset()
    player = controller
    
    computer.reset()
    // don't set up auto-input until after reset() because reset() tries to flush input
    computer.ReadInputCallback = \-> {
      inputCount += 1
      //print("${inputCount} inputs read, t=${computer.Clock}")
      return player.getCommand()
    }
    computer.WriteOutputCallback = \value:long -> {
      outputCount += 1
      //print("${outputCount} outputs written, t=${computer.Clock}") // noisy
      return handleOutput(value as int)
    }
    
    player.beginPlay(this)
    computer.run()

    print("halt ${computer.Halt}")
    print("waiting for input ${computer.WaitingForInput}")
    print("waiting for output ${computer.WaitingForOutput}")
    print("error ${computer.Error}")
  }
  
  function renderDisplay() {
    print("\tscore: ${score}")
    var credit = checkCredit()
    if(credit != 2) print("\tINSERT COIN")
    print(display.render(game_legend))
    //print("(${display.Count} screen tiles)")
    //print("(${outputCount} display updates)")
  }
}

abstract static class BreakoutPlayer implements IBreakoutPlayer {
  abstract override function sensePaddle(x : int)
  abstract override function senseBall(x : int)
  abstract override function getCommand() : int
  
  var cabinet : ArcadeCabinet as Cabinet
  override function beginPlay(game : ArcadeCabinet) {
    cabinet = game
  }
}

static class BreakoutRobot extends BreakoutPlayer {
  var paddle_x : Integer
  var ball_x : Integer
  var last_display : long
  construct() {
    paddle_x = null
    ball_x = null
  }
  override function sensePaddle(x : int) {
    if(x != paddle_x) {
      print("paddle at x=${paddle_x}")
    }
    paddle_x = x
  }
  override function senseBall(x : int) {
    if(x != ball_x) {
      print("ball at x=${ball_x}")
      var now = System.currentTimeMillis()
      if(now > last_display + 10000) {
        last_display = now
        cabinet.renderDisplay()
        java.lang.Thread.sleep(1000)
      }
    }
    ball_x = x
  }
  override function getCommand() : int {
    var stick : int
    if(paddle_x == ball_x) stick = 0
    else if(paddle_x < ball_x) stick = 1
    else stick = -1
    
    print("get input: ${paddle_x} --[${stick}]--> ${ball_x}")
    return stick
  }
}

static class ConsoleInputReader extends BreakoutPlayer {
  override function sensePaddle(x : int) {
    print("paddle seen at ${x}")
  }
  
  override function senseBall(x : int) {
    print("ball seen at ${x}")
  }
  
  override function getCommand() : int {
    cabinet.renderDisplay()
    
    print("joystick please, 1/2/3")
    var line = new java.io.BufferedReader(new java.io.InputStreamReader(System.in)).readLine().trim()
    if(line.contains("!")) cabinet.insertQuarters()
    
    return {
      "1" -> -1,
      "2" ->  0,
      "3" ->  1
    }.getOrDefault(line, 0)
  }
}

static class BreakoutTAS extends BreakoutPlayer {
  var inputData : Iterable<Direction>
  var inputSequence : Iterator<Direction>
  
  construct(input : Iterable<Direction>) {
    inputData = input
  }
  
  override function beginPlay(game : ArcadeCabinet) {
    super.beginPlay(game)
    inputSequence = inputData.iterator()
  }
    
  override function sensePaddle(x : int) {
    // don't care, we're recorded
  }
  
  override function senseBall(x : int) {
    // meh
  }
  
  override function getCommand() : int {
    Cabinet.renderDisplay()
    
    var stick : Direction = null
    if(inputSequence.hasNext()) stick = inputSequence.next()
    var output = {
      Direction.L -> -1,
      Direction.R ->  1
    }.getOrDefault(stick, 0)
    print("BreakoutTAS replay ${output}")
    return output
  }
}

var player =
  new BreakoutRobot()
  //new ConsoleInputReader()
  //new BreakoutTAS({L, L, L, L, L, L, L, L, L, L, L})

var gameRoom = new ArcadeCabinet(arcade_program)

//;{ // count blocks for Day 1 answer
//    var categories = gameRoom.display.Values.toList().partition(\pixel -> pixel.value)
//    for(category in game_legend_names.entrySet().orderBy(\es -> es.Key)) {
//      var value = category.Key // um...
//      var name = category.Value
//      var symbol = game_legend[value]
//      var count = categories.containsKey(value) ? categories[value].Count : 0
//      print("${name} (${symbol}): ${count}")
//    }
//};

// day 2 : play the game
gameRoom.insertQuarters()
gameRoom.run(player)
gameRoom.renderDisplay() // one last time to make sure we find out the final score
