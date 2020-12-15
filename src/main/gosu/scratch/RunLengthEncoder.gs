package scratch
uses gw.util.Pair

class RunLengthEncoder<T> implements Iterator<Pair<T, Integer>> {
  var stream : Iterator<T>
  var last : T
  var count : int
  var output : Pair<T, Integer>
  
  construct(source : Iterator<T>) {
    stream = source
    last = null
    count = 0
    output = null
  }
  
  function scan() {
    if(output != null) return
    
    while(stream.hasNext()) {
      var next = stream.next()
      if(last == null) {
        last = next
        count = 0
      }
      if(next == last) {
        count += 1
      } else {
        output = gw.util.Pair.make(last, count)
        last = next
        count = 1
        return
      }
    }
    if((not stream.hasNext()) and last != null) {
      output = gw.util.Pair.make(last, count)
      last = null
    }
  }
  
  override function hasNext() : boolean {
    scan()
    return output != null
  }
  
  override function next() : Pair<T, Integer> {
    try {
      scan()
      return output
    } finally {
      output = null
    }
  }
}
