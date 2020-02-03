uses scratch.IterableEnhancement

/**
 * Day 10: Monitoring Station
 * 
 * Part 1:
 * given a map of asteroid locations, find the best asteroid to build a monitoring station
 * sensors can track any asteroid that is in a direct line of sight and not behind another asteroid
 * 
 * the best location will be on the asteroid that has an unblocked view of the greatest number of other asteroids
 * locations reported in X-Y coordinates
 *   positive X -> right
 *   positive Y -> down
 *   origin is the top left corner
 * 
 * Part 2:
 * all the asteroids save the location of the new monitoring station, will be vaporized by a GIANT LASER
 * laser points 'up' (negative Y) and then rotates clockwise
 * laser will vaporize the first asteroid it sees in direct line of sight along any specific angle before continuing to rotate
 *   therefore 'hidden' asteroids will only be targeted on subsequent rotations, after they become visible
 * 
 * determine which asteroid will be the 200th to be vaporized
 * report coordinates as X*100 + Y
 */

static class Point {
  var x : int
  var y : int
  
  construct(xCoord : int, yCoord : int) {
    x = xCoord
    y = yCoord
  }
  
  construct(that : Point) {
    x = that.x
    y = that.y
  }
  
  override function toString() : String {
    return "(${x}, ${y})"
  }
  
  override function equals(that : Object) : boolean {
    if(that typeis Point) {    
      return this.x == that.x and this.y == that.y
    } else {
      return false
    }
  }
  
  function subtract(that : Point) : Point {
    return new Point(this.x - that.x, this.y - that.y)
  }
  
  function distance(that : Point) : double {
    return Math.sqrt(Math.pow(that.x - this.x, 2) + Math.pow(that.y - this.y, 2))
  }
  
  function dotProduct(that : Point) : int /* since we're promised to always be on a grid */ {
    return this.x * that.x + this.y * that.y
  }
  
  function parallel(that : Point) : boolean {
    return (this.y * that.x == this.x * that.y) and (this.dotProduct(that) > 0)
  }
  
  property get Angle() : double {
    return Math.atan2(x, y) + Math.PI
  }
}

static class SpaceMap {
  var asteroids : Collection<Point>
  var width : int
  var height : int
  protected var observer : Point
  
  construct(mapData : String) {
    asteroids = new HashSet<Point>()
    for(line in new Scanner(mapData) index y) {
      for(column in new Scanner(line).useDelimiter("") index x) {
        switch(column) {
          case "#":
            asteroids.add(new Point(x,y))
            break
          case "O":
            observer = new Point(x,y)
            break
          case ".":
            // okay
            break
          default:
            throw new IllegalArgumentException("what is '${column}' doing here?")
        }
        width = x
      }
      height = y
    }
    width += 1
    height += 1
    observer = null
    //print("SpaceMap(String) scanned ${asteroids.Count} in ${width}x${height}")
  }
  
  construct(otheroids : Collection<Point>, otherWidth : int, otherHeight : int) {
    asteroids = new HashSet<Point>(otheroids)
    width += otherWidth
    height += otherHeight
    observer = null
    //print("SpaceMap(Collection, int, int) copied ${asteroids.Count} in ${width}x${height}")
  }
  
  construct(that : SpaceMap) {
    asteroids = new HashSet<Point>(that.asteroids)
    width = that.width
    height = that.height
    Observer = that.observer
  }
  
  property get Observer() : Point {
    return observer
  }
  property set Observer(obs : Point) {
    observer = obs == null ? null : new Point(obs)
  }
  
  property get Count() : int {
    return asteroids.Count
  }
  
  override function toString() : String {
    var linebreak = "\n"
    var buffer = new StringBuilder()
    for(y in 0..|height) {
      buffer.append(".".repeat(width))
      buffer.append(linebreak)
    }
    var insertAt = \asteroid : Point -> asteroid.y * (width + linebreak.length) + asteroid.x
    for(asteroid in asteroids) {
      var pos = insertAt(asteroid)
      if(buffer.substring(pos, pos+1) == linebreak) throw new IllegalStateException("replacing line break with content value")
//      print(buffer.toString())
//      print("${asteroid.x},${asteroid.y} -> ${pos}")
      var pre = buffer.length()
      buffer.replace(pos, pos+1, "#")
      if(buffer.length() != pre) throw new IllegalStateException("replacement changed buffer length")
    }
    if(observer != null) {
      var pos = insertAt(observer)
      buffer.replace(pos, pos+1, "O")
    }
    return buffer.toString()
  }
  
  function getNeighbors(origin : Point) : SpaceMap {
    var visible = new HashSet<Point>()
    for(incoming in asteroids) {
      if(incoming.equals(origin)) continue
      
      var parallel = visible.firstWhere(\neighbor -> incoming.subtract(origin).parallel(neighbor.subtract(origin)))
      if(parallel != null) {
        if(origin.distance(incoming) < origin.distance(parallel)) { // found something closer
          visible.remove(parallel)
          visible.add(incoming)
        }
        // else farther away, don't add it
      } else { // not parallel, can't occlude
        visible.add(incoming)
      }
    }
    //print("${origin} has ${visible.Count} visible neighbors")
    var map = new SpaceMap(visible, width, height)
    map.Observer = origin
    return map
  }
  
  function subtract(that : SpaceMap) : SpaceMap {
    return new SpaceMap(asteroids.subtract(that.asteroids), width, height)
  }
  
  function laserPass() : List<Point> {
    return asteroids
      .orderBy(\p -> (2*Math.PI - p.subtract(observer).Angle) % (2*Math.PI))
      .thenBy(\p -> Observer.distance(p)) // not necessary for the puzzle but if the laser were strong enough to hit them all at once, this is what would happen
  }
  
  function laserOrder() : List<Point> {
    if(Observer == null) return null // we don't have our own GIANT LASER yet
    
    var objectsInSpace = new SpaceMap(this)
    var laserOrder = new ArrayList<Point>()
    while(objectsInSpace.Count > 1 /* monitoring station won't laser itself */) {
      var nextRound = objectsInSpace.getNeighbors(Observer)
//      print("to be lasered:")
//      print(nextRound)
      laserOrder.addAll(nextRound.laserPass())
      objectsInSpace = objectsInSpace.subtract(nextRound)
    }
    return laserOrder
  }
}


for(data in {
   ""
  ,"#"
  ,"..\n.."
  ,"..\n#."
  ,"###"
  ,"#\n#\n#"
  ,"###\n###\n###"
  ,"####\n#..."
  ,"###########################"
  
  // 3,4 -> 8
  ,".#..#\n.....\n#####\n....#\n...##"
  
  // 5,8 -> 33
  ,"......#.#.\n#..#.#....\n..#######.\n.#.#.###..\n.#..#.....\n..#....#.#\n#..#....#.\n.##.#..###\n##...#..#.\n.#....####"
  
  // 1,2 -> 35
  ,"#.#...#.#.\n.###....#.\n.#....#...\n##.#.#.#.#\n....#.#.#.\n.##..###.#\n..#...##..\n..##....##\n......#...\n.####.###.\n"

  // 6,3 -> 41
  ,".#..#..###\n####.###.#\n....###.#.\n..###.##.#\n##.##.#.#.\n....###..#\n..#.#..#.#\n#..#.#.###\n.##...##.#\n.....#.#..\n"
  
  // 11,13 -> 210
  ,".#..##.###...#######\n##.############..##.\n.#.######.########.#\n.###.#######.####.#.\n#####.##.#.##.###.##\n..#####..#.#########\n####################\n#.####....###.#.#.##\n##.#################\n#####.##.###..####..\n..######..##.#######\n####.##.####...##..#\n.#####..#.######.###\n##...#.##########...\n#.##########.#######\n.####.#.###.###.#.##\n....##.##.###..#####\n.#.#.###########.###\n#.#.#.#####.####.###\n###.##.####.##.#..##\n"

  ,scratch.Util.getPuzzleInput("Day10-input.txt")
}) {
  print("\n")
  var map = new SpaceMap(data)
  print("${map.asteroids.Count} asteroids")
  print(map)
  if(map.asteroids.Count == 0) {
    print("space is empty")
    continue
  }
  var bestAsteroid : Point
  var neighbors : SpaceMap
  ;{
    var distances = map.asteroids.mapToKeyAndValue(\p -> p, \p -> map.getNeighbors(p))
    var bestLocation = distances.entrySet().maxBy(\entry -> entry.Value.Count)
    bestAsteroid = bestLocation.Key
    neighbors = bestLocation.Value
  };
  print("-> ${bestAsteroid} has ${neighbors.Count} neighbors:")
  print(neighbors)
  map.Observer = bestAsteroid
  var laserOrder = map.laserOrder()
  if(laserOrder.Count < 20) {
    print("asteroids to be lasered:")
    print(laserOrder.join(" -> "))
  }
  if(laserOrder.Count >= 200) {
    var twoHundredth = laserOrder[200-1]
    print("asteroid ${twoHundredth} will be the 200th to be vaporized")
    print("coordinate key X*100 + Y = ${twoHundredth.x * 100 + twoHundredth.y}")
  }
}
