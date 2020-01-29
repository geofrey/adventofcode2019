package scratch

enhancement IterableEnhancement<T> : Iterable<T> {
  function mapToKeyAndValue<K,V>(toKey : block(item:T):K, toValue : block(item:T):V) : Map<K,V> {
    var map = new HashMap<K,V>()
    for(item in this) {
      var key = toKey(item)
      var existing = map.getOrDefault(key, null)
      if(existing != null and item != existing) {
        throw new Exception("${existing} and ${item} both map to ${key}")
      }
      var value = toValue(item)
      map.put(key, value)
    }
    return map
  }
}