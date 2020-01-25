uses java.io.File
uses java.io.FileInputStream

/**
 * Day 1: The Tyranny of the Rocket Equation
 * 
 * fuel-required is module mass divided by 3, rounded down, minus 2
 * 
 * Day 1, part 2:
 * 
 * fuel-required also requires fuel
 * iteratively add fuel based on the same formula until the change is no longer positive
 */
 
// inspected inputs; no tiny values present to return negative-fuel nonsense
function fuelRequirement(weight : long) : long {
 return weight / 3 - 2
}

function iteratedFuelRequirement(weight : long) : long {
  var totalFuel : long = 0
  var fuel = fuelRequirement(weight)
  while(fuel > 0) {
    //print("(add ${fuel} fuel)")
    totalFuel += fuel
    fuel = fuelRequirement(fuel)
  }
  return totalFuel
}

var inputSource = new File("src/main/gosu/days/Day1-input.txt").CanonicalFile
print(inputSource.AbsolutePath)
var input = new Scanner(new FileInputStream(inputSource))

var modules = new ArrayList<Long>()

for(line in input) {
 var moduleWeight = Long.parseLong(line)
 modules.add(moduleWeight)
}

var totalModuleWeight = modules.sum()
var fuelWeight = modules.map(\module -> iteratedFuelRequirement(module)).sum()
print("modules: ${modules.Count}")
print("total module weight : ${totalModuleWeight}")
print("fuel requirement: ${fuelWeight}")
print("(total mission weight: ${totalModuleWeight + fuelWeight})")
