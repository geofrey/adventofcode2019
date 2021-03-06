package scratch

class IntegerPoint {
  public var x : int
  public var y : int
  
  construct(xCoord : int, yCoord : int) {
    x = xCoord
    y = yCoord
  }
  
  construct(that : IntegerPoint) {
    x = that.x
    y = that.y
  }
  
  override function toString() : String {
    return "(${x}, ${y})"
  }
  
  override function equals(that : Object) : boolean {
    if(that typeis IntegerPoint) {    
      return this.x == that.x and this.y == that.y
    } else {
      return false
    }
  }
  
  public static function cantor_pair(x : int, y : int) : int {
    var ax = Math.abs(x)
    var ay = Math.abs(y)
    var diagonalized = (ax + ay)*(ax + ay + 1)/2 + ay
    // Cantor's pairing function is defined for natural numbers; we need to handle all integers
    // offset by quadrant
    diagonalized *= 4
    if(x < 0) diagonalized += 2
    if(y < 0) diagonalized += 1
    return diagonalized
  }
  
  override function hashCode() : int {
    return cantor_pair(x, y)
  }
  
  function subtract(that : IntegerPoint) : IntegerPoint {
    return new IntegerPoint(this.x - that.x, this.y - that.y)
  }
  
  function distance(that : IntegerPoint) : double {
    return Math.sqrt(Math.pow(that.x - this.x, 2) + Math.pow(that.y - this.y, 2))
  }
  
  function dotProduct(that : IntegerPoint) : int /* since we're promised to always be on a grid */ {
    return this.x * that.x + this.y * that.y
  }
  
  function parallel(that : IntegerPoint) : boolean {
    return (this.y * that.x == this.x * that.y) and (this.dotProduct(that) > 0)
  }
  
  property get Angle() : double {
    return Math.atan2(x, y) + Math.PI
  }
}