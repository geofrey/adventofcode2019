package scratch

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
  
  static function permute(list : int[], order : int[]) : int[] {
    var permutation = new int[list.length]
    for(i in 0..|list.length) permutation[i] = list[order[i]]
    return permutation
  }
}