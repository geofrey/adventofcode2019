package scratch

class RasterCloud implements Map<Integer, RasterPoint> {
  delegate pixels represents Map<Integer, RasterPoint>
  
  final function init() {
    pixels = new HashMap<Integer, RasterPoint>()
  }
  construct() {
    init()
  }
  
  property get Pixels() : Collection<RasterPoint> {
    return pixels.Values
  }
  
  function draw(x : int, y : int, color : int) {
    //print("draw ${x},${y} <- ${color}")
    var hash = IntegerPoint.cantor_pair(x, y)
    var pixel : RasterPoint
    if(pixels.containsKey(hash)) {
      pixel = pixels.get(hash)
      print("draw onto existing pixel ${pixel}")
    } else {
      pixel = new RasterPoint(x, y)
      pixels.put(hash, pixel)
      //print("add new pixel")
    }
    pixel.value = color
  }
  
  function findBounds() : Map<Direction, Integer> {
    var top = Integer.MIN_VALUE
    var bottom = Integer.MAX_VALUE
    var left = Integer.MAX_VALUE
    var right = Integer.MIN_VALUE
  
    for(point in Pixels) {
      if(point.x < left) left = point.x
      if(right < point.x) right = point.x
      if(point.y < bottom) bottom = point.y
      if(top < point.y) top = point.y
    }
  
    return {U -> top, D -> bottom, L -> left, R -> right}
  }
  
  function render(colors : Map<Integer, String>) : String {
    var bounds = findBounds()
    var width = bounds[R]-bounds[L]+1
    var height = bounds[U]-bounds[D]+1
    var image = new Integer[width][height]
    var transformX = \x:int -> x+bounds[L]
    var transformY = \y:int -> y+bounds[D]
    
    //print("grid ${width}x${height} (${bounds[L]}->${bounds[R]} x ${bounds[D]}->${bounds[U]})")
    
    var text = new StringBuilder()
    for(y in 0..|height) {
      for(x in 0..|width) {
        var hash = IntegerPoint.cantor_pair(x, y)
        if(pixels.containsKey(hash)) {
          text.append(colors[pixels.get(hash).value])
        } else {
          text.append(" ")
        }
      }
      //text.append(" line ${y}")
      text.append("\n")
    }
    return text.toString()
  }
}
