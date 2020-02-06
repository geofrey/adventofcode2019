package scratch

class Maperator<F,T> implements Iterator<T> {
  var mapper : block(from:F):T
  var source : Iterator<F>
  
  construct(underlyingIterator : Iterator<F>, transformation(from:F):T) {
    source = underlyingIterator
    mapper = transformation
  }
  
  override function hasNext() : boolean {
    return source.hasNext()
  }
  
  override function next() : T {
    return mapper(source.next())
  }
}
