uses java.io.File

var inputLocation = new File(
  System.Properties.getProperty("user.dir"),
  "src/main/gosu/days/Day8-input.txt"
)
var input = inputLocation.read().trim()

var width = 25
var height = 6
var layers = input.length() / (width * height)

var image = new int[layers][width][height]

var inputStream = new Scanner(input).useDelimiter("")
for(layer in 0..|layers)
  for(y in 0..|height)
    for(x in 0..|width)
      image[layer][x][y] = inputStream.nextInt()

function countDigits(layer : int[][], target : int) : int {
  var count = 0
  for(x in 0..|width)
    for(y in 0..|height)
      if(layer[x][y] == target)
        count += 1
  return count
}

var zeroCounts = new HashMap<Integer, Integer>()
for(layer in 0..|layers) zeroCounts.put(layer, countDigits(image[layer], 0))
var leastZeroes = zeroCounts.entrySet().minBy(\entry -> entry.Value).Key
print("least zeroes on layer ${leastZeroes}")
var ones = countDigits(image[leastZeroes], 1)
var twos = countDigits(image[leastZeroes], 2)
print("${ones} ones x ${twos} twos = ${ones * twos}")

function visible() : int[][] {
  var result = new int[width][height]
  for(x in 0..|width) {
    for(y in 0..|height) {
      for(layer in 0..|layers) {
        result[x][y] = image[layer][x][y]
        if(result[x][y] != 2) {
          break
        }
      }
    }
  }
  return result
}

var colors = {
  0 -> "`", // "black"
  1 -> "#", // "white"
  2 -> " "  // transparent
}

function render(layer : int[][]) : String {
  var output = new StringBuilder()
  for(y in 0..|height) {
    for(x in 0..|width) {
      output.append(colors[layer[x][y]])
    }
    output.append("\n")
  }
  return output.toString()
}

print("visible image:")
print(render(visible()))

