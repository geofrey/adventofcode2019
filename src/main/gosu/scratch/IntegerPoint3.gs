package scratch

class IntegerPoint3 {
  public var x : int
  public var y : int
  public var z : int
  
  construct(xCoord : int, yCoord : int, zCoord : int) {
    x = xCoord
    y = yCoord
    z = zCoord
  }
  
  construct(that : IntegerPoint3) {
    x = that.x
    y = that.y
    z = that.z
  }
  
  // I have a feeling I'm going to need this
  public static function triple(x : int, y : int, z : int) : int {
    return IntegerPoint.cantor_pair(IntegerPoint.cantor_pair(x, y), z)
  }
  
  override function toString() : String {
    //return "<x=${x}, y=${y}, z=${z}>"
    return String.format("<x=% 3d, y=% 3d, z=% 3d>", {x, y, z})
  }
  
  override function equals(that : Object) : boolean {
    if(that typeis IntegerPoint3) return this.x == that.x and this.y == that.y and this.z == that.z
    else return false
  }
}