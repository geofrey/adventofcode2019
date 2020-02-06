package scratch

enum Direction {
  R,
  L,
  U,
  D
  
  private static final var CLOCKWISE : Map<Direction, Direction> = {U->R, R->D, D->L, L->U}
  property get succ() : Direction {
    return CLOCKWISE.get(this)
  }
  
  private static final var COUNTERCLOCKWISE : Map<Direction, Direction> = {U->L, L->D, D->R, R->U}
  property get pred() : Direction {
    return COUNTERCLOCKWISE.get(this)
  }
}
