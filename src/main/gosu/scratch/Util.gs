package scratch
uses java.io.File
uses gw.util.Pair

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
  
  static reified function permute<T>(list : List<T>, order : int[]) : List<T> { // language versions???
  //static function permute<T>(list : List<T>, order : int[]) : List<T> {
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
  
  static function cartesianProduct<T,U>(left : Collection<T>, right : Collection<U>, ordered : boolean = true) : Set<Pair<T,U>> {
    var product = new HashSet<Pair<T,U>>()
    for(a in left) for(b in right) {
      if(ordered or not product.contains(Pair.make(b, a))) {
        product.add(Pair.make(a, b))
      }
    }
    return product
  }
  
  static function gcd(a : long, b : long) : long {
    var temp : long
    while(a > 0) {
      if(a < b) {
        temp = b
        b = a
        a = temp
      }
      a -= b
    }
    return b
  }
  static function gcd(numbers : List<Long>) : long {
    return numbers.fold(\a,b -> gcd(a, b))
  }
  
  static function lcm(a : long, b : long) : long {
    return Math.abs(a * b) / gcd(a, b)
  }
  static function lcm(numbers : List<Long>) : long {
    return numbers.fold(\a,b -> lcm(a, b))
  }
  
  static function primeFactors(n : long) : List<Long> {
    var factors = new ArrayList<Long>()
    var candidate = 2
    while(candidate <= n) {
      var quotient = n / candidate
      if(quotient * candidate == n) {
        n = quotient
        factors.add(candidate)
      } else {
        candidate += 1
      }
    }
    return factors
  }
  
  static function condense<T>(items : List<T>) : List<Pair<T, Integer>> {
    var runs = new ArrayList<Pair<T, Integer>>()
    var last : T = null
    var count = 0
    for(next in items) {
      if(next == last) {
        count += 1
      } else if(count > 0) {
        runs.add(Pair.make(last, count))
        count = 1
      }
      last = next
    }
    return runs
  }
}