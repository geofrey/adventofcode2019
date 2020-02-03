package scratch

enhancement IterableEnhancement<T> : Iterable<T> {
  function mapToKeyAndValue<K,V>(mkKey(item:T):K, mkValue(item:T):V) : Map<K,V> {
    var theMap = new HashMap<K,V>()
    for(item in this) {
      var key = mkKey(item)
      var value = mkValue(item)
      if(theMap.containsKey(key)) {
        throw new IllegalArgumentException("Key collision: ${theMap.get(key)} and ${item} both map to ${value}.")
      }
      theMap.put(key, value)
    }
    return theMap
  }
}
