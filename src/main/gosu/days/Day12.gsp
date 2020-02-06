/**
 * Day 12: N-Body Problem
 * 
 * Really REALLY simplified physics
 * 
 * Movement
 * - every moon has the same mass. Or, mass doesn't affect gravitation
 * - every pair of moons affects the velocity of both moons
 *   along each axis (x, y, z), add or subtract 1 velocity to accelerate the moons toward each other
 *   i.e. if moon A is lower on the x-axis than moon B then A's x velocity gets += 1 and B's x velocity gets += -1
 * - each time step, every moon moves according to its updated velocity vector
 * 
 * Energy
 * - potential energy is the sum of the absolute values of a body's coordinates
 * - kinetic energy is the sum of the absolute values of a body's velocity components
 * - total energy is the product(!) of a body's potential and kinetic energies
 * 
 * Part 1:
 * What is the total energy of the entire scanned planetary system (puzzle input) after simulating for 1000 steps?
 * 
 */

// this one's short
var puzzleInput = "<x=-13, y=-13, z=-13>\
<x=5, y=-8, z=3>\
<x=-6, y=-10, z=-3>\
<x=0, y=5, z=-5>\
"

