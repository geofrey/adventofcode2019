package scratch
uses java.io.File

class Util {
  static function factorial(n : int) : int {
    return (1..n).fold(\l,r -> l*r)
  }
  
  static function nthderangement(n : int, count : int) : int[] {
    n = n % factorial(count) // normalize
    var sequence = (0..|count).toList()
    var result = new int[count]
    while(sequence.Count > 1) {
      var fact = factorial(sequence.Count-1)
      var pos = n / fact
      n = n % fact
      result[count-sequence.Count] = sequence.remove(pos)
    }
    result[count-1] = sequence[0]
    return result
  }
  
  static reified function permute<T>(list : List<T>, order : int[]) : List<T> {
    var permutation = new ArrayList<T>()
    for(i in 0..|list.Count) permutation.add(list[order[i]])
    return permutation
  }
  
  static function getPuzzleInput(fileName : String) : String {
    var folder = new File(
      System.Properties.getProperty("user.dir"), // this is no good when debugging; user.dir gets set differently
      "src/main/gosu/days"
    )
    var inputFile = new File(folder, fileName)
    return inputFile.read()
  }
  
  static function csvLongs(line : String) : Long[] {
    return new Maperator(new Scanner(line.trim()).useDelimiter(","), \text -> Long.parseLong(text)).toList().toTypedArray()
  }
}