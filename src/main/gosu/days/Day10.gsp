uses scratch.IterableEnhancement
uses scratch.IntegerPoint

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



static class SpaceMap {
  var asteroids : Collection<IntegerPoint>
  var width : int
  var height : int
  protected var observer : IntegerPoint
  
  construct(mapData : String) {
    asteroids = new HashSet<IntegerPoint>()
    for(line in new Scanner(mapData) index y) {
      for(column in new Scanner(line).useDelimiter("") index x) {
        switch(column) {
          case "#":
            asteroids.add(new IntegerPoint(x,y))
            break
          case "O":
            observer = new IntegerPoint(x,y)
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
  
  construct(otheroids : Collection<IntegerPoint>, otherWidth : int, otherHeight : int) {
    asteroids = new HashSet<IntegerPoint>(otheroids)
    width += otherWidth
    height += otherHeight
    observer = null
    //print("SpaceMap(Collection, int, int) copied ${asteroids.Count} in ${width}x${height}")
  }
  
  construct(that : SpaceMap) {
    asteroids = new HashSet<IntegerPoint>(that.asteroids)
    width = that.width
    height = that.height
    Observer = that.observer
  }
  
  property get Observer() : IntegerPoint {
    return observer
  }
  property set Observer(obs : IntegerPoint) {
    observer = obs == null ? null : new IntegerPoint(obs)
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
    var insertAt = \asteroid : IntegerPoint -> asteroid.y * (width + linebreak.length) + asteroid.x
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
  
  function getNeighbors(origin : IntegerPoint) : SpaceMap {
    var visible = new HashSet<IntegerPoint>()
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
  
  function laserPass() : List<IntegerPoint> {
    return asteroids
      .orderBy(\p -> (2*Math.PI - p.subtract(observer).Angle) % (2*Math.PI))
      .thenBy(\p -> Observer.distance(p)) // not necessary for the puzzle but if the laser were strong enough to hit them all at once, this is what would happen
  }
  
  function laserOrder() : List<IntegerPoint> {
    if(Observer == null) return null // we don't have our own GIANT LASER yet
    
    var objectsInSpace = new SpaceMap(this)
    var laserOrder = new ArrayList<IntegerPoint>()
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
  var bestAsteroid : IntegerPoint
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
