package scratch
uses gw.lang.reflect.interval.IntegerInterval

class SpaceImage {
  public var width : int
  public var height : int
  public var depth : int
  public var data : int[][][]
  
  construct(imageWidth : int, imageHeight : int, input : String) {
    input = input.trim()
    width = imageWidth
    height = imageHeight
    depth = input.length() / (width * height)
    data = new int[depth][width][height]
    var inputStream = new Scanner(input).useDelimiter("")
    for(layer in 0..|depth)
      for(y in 0..|height)
        for(x in 0..|width)
          data[layer][x][y] = inputStream.nextInt()
  }
  
  construct(singleLayer : int[][]) {
    width = singleLayer.length
    height = singleLayer[0].length
    depth = 1
    data = {singleLayer.copy()}
  }
  
  static function blankImage(imageWidth : int, imageHeight : int, backgroundColor : int) : SpaceImage {
    var layer = new int[imageWidth][imageHeight]
    for(j in 0..|imageHeight)
      for(i in 0..|imageWidth)
        layer[i][j] = backgroundColor
    return new SpaceImage(layer)
  }
  
  function getLayer(layer : int) : int[][] {
    return data[layer]
  }
  
  function visible() : int[][] {
    var result = new int[width][height]
    for(x in 0..|width) {
      for(y in 0..|height) {
        for(layer in 0..|depth) {
          result[x][y] = data[layer][x][y]
          if(result[x][y] != 2) {
            break
          }
        }
      }
    }
    return result
  }
  
  static final var colors = {
    0 -> ".", // "black"
    1 -> "#", // "white"
    2 -> " "  // transparent
  }

  static function render(layer : int[][], xOrder : IntegerInterval, yOrder : IntegerInterval) : String {
    var output = new StringBuilder()
    for(y in yOrder) {
      for(x in xOrder) {
        output.append(colors[layer[x][y]])
      }
      output.append("\n")
    }
    return output.toString()
  }
  
  static function render(layer : int[][]) : String {
    return render(layer, 0..|layer.length, 0..|layer[0].length)
  }
  
  static function render_upsideDown(layer : int[][]) : String {
    return render(layer, 0..|layer.length, layer[0].length|..0)
  }
  
  function render() : String {
    return render(visible())
  }
  
  function render_upsideDown() : String {
    return render_upsideDown(visible())
  }
}
