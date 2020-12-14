//scratch.intcode.IntcodeDisassembler.executeWithArgs({"-p", "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"})
var legend = {
  0 -> ".",
  1 -> "#"
}
var smallCloud = new RasterCloud()
smallCloud.draw(0, 0, 1)
print(smallCloud.render(legend))
smallCloud.draw(0, 0, 0)
print(smallCloud.render(legend))
