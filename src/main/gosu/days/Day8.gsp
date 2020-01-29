uses scratch.Util
uses scratch.IterableEnhancement
uses java.util.regex.Pattern

/**
 * Day 8: Space Image Format
 * 
 * - raster image, one digit per pixel
 * - row-major, left-to-right, top-to-bottom
 * - there are layers so it's really layer-major...whatever
 * - lowest layers are on top
 * - 0: black, 1: white, 2: transparent
 * 
 * Puzzle input is a SIF image
 * 
 * - image is 25x6
 * - - well, part 1 is, at least
 * - gosh that's a big input. must be lots of layers.
 */

var input = Util.getPuzzleInput("Day8-input.txt").trim()
var inputLength = input.length
var width = 25
var height = 6
var layers = inputLength / (width * height)
print("image data length ${inputLength}, ${width}x${height}x${layers}")
if(width * height * layers != inputLength) {
  print("Data length is not an even multiple of image dimensions! Shenanigans detected!")
}

var image = new int[layers][width][height]
var dataStream = new Scanner(input).useDelimiter(Pattern.compile(""))
for(layer in 0..|layers)
  for(x in 0..|width)
    for(y in 0..|height)
      image[layer][x][y] = Integer.parseInt(dataStream.next())

function countDigits(layer : int, target : int) : int {
  var total = 0
  for(x in 0..|width)
    for(y in 0..|height)
      if(image[layer][x][y] == target)
        total += 1
  return total
}

var zeroCounts = (0..|layers).mapToKeyAndValue(\i->i, \i-> countDigits(i, 0))
var lowest = zeroCounts.entrySet().minBy(\entry -> entry.Value).Key

print("layer ${lowest} has the fewest zeroes (${zeroCounts.get(lowest)})")
var ones = countDigits(lowest, 1)
var twos = countDigits(lowest, 2)
print("${ones} 1s x ${twos} 2s = ${ones * twos}")

// 924 too low
// indexing was all off
// layer 13, 3 zeroes, 17 1s x 130 2s = 2210

//var columns = new LinkedHashMap<String, block(layer:int):Object>()
//columns.put("layer", \i -> i)
//columns.put("0", \i -> countDigits(i, 0))
//columns.put("1", \i -> countDigits(i, 1))
//columns.put("2", \i -> countDigits(i, 2))
//columns.put("1x2", \i -> countDigits(i, 1) * countDigits(i, 2))
//
//print(columns.Keys.join("\t"))
//for(layer in 0..|layers) {
//  print(columns.Values.map(\generate -> generate(layer)).join("\t"))
//}

var colors = {
  0 -> ".", // "black"
  1 -> "#", // "white"
  2 -> " "  // transparent
}

function renderLayer(layer : int[][]) : String {
  var output = new StringBuilder()
  for(y in 0..|height) {
    for(x in 0..|width) {
      output.append(colors.get(layer[x][y]))
    }
    output.append("\n")
  }
  return output.toString()
}

for(layer in 0..|layers) {
  print("layer ${layer}:")
  print(renderLayer(image[layer]))
  print("")
}

function getVisible() : int[][] {
  var visible = new int[width][height]
  for(x in 0..|width) {
    for(y in 0..|height) {
      for(layer in 0..|layers) {
        visible[x][y] = image[layer][x][y]
        if(visible[x][y] != 2) break // non-transparent pixels occlude lower layers so stop here
      }
    }
  }
  return visible
}

print("visible image:")
print(renderLayer(getVisible()))
