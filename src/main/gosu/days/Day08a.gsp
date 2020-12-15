uses java.io.File
uses scratch.Maperator
uses scratch.SpaceImage

var inputLocation = new File(
  System.Properties.getProperty("user.dir"),
  "src/main/gosu/days/Day8-input.txt"
)

var input = inputLocation.read().trim()

var width = 25
var height = 6

var image = new SpaceImage(width, height, input)

function countDigits(spaceImage : SpaceImage, layerNum : int, color : int) : int {
  var layer = spaceImage.getLayer(layerNum)
  var count = 0
  for(x in 0..|width)
    for(y in 0..|height)
      if(layer[x][y] == color)
        count += 1
  return count
}

var zeroCounts = new HashMap<Integer, Integer>()
for(layer in 0..|image.depth) zeroCounts.put(layer, countDigits(image, layer, 0))
var leastZeroes = zeroCounts.entrySet().minBy(\entry -> entry.Value).Key
print("least zeroes on layer ${leastZeroes}")
var ones = countDigits(image, leastZeroes, 1)
var twos = countDigits(image, leastZeroes, 2)
print("${ones} ones x ${twos} twos = ${ones * twos}")





print("visible image:")
//print(render(visible()))
print(image.render(image.visible()))
