package scratch

enhancement IteratorEnhancement<T> : Iterator<T> {
  function cdr() : Iterator<T> {
    // not checking hasNext() first; caveat delegator
    this.next()
    return this
  }
}
