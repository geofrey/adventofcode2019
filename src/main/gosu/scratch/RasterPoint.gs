package scratch

class RasterPoint extends IntegerPoint {
  public var value : Integer
  construct(xCoord : int, yCoord : int) {
    super(xCoord, yCoord)
  }
  construct(other : IntegerPoint) {
    super(other)
  }
  construct(point : IntegerPoint, data : int) {
    super(point)
    value = data
  }
  
  override function toString() : String {
    return "(${x}, ${y})[${value}]"
  }
}