package scratch

class Generator<T> implements Iterator<T>, Iterable<T> {
  var generate : block():T
  var item : T
  construct(source : block(): T) {
    generate = source
  }
  
  protected function get() {
    if(item == null) item = generate()
  }
  
  override function hasNext() : boolean {
    get()
    return item != null
  }
  
  override function next() : T {
    get()
    var out1 = item
    item = null
    return out1
  }
  
  override function remove() {
    get()
    item = generate() // burn one
  }
  
  override function iterator() : Iterator<T> {
    return this
  }
  
}