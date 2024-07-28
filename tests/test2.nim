import tilengine

proc main() =
  let e = init(320, 224, 4, 64, 64)
  setLoadPath("./assets")
  let fg = loadBitmap("elis2.png")
  Layer(0).setBitmap(fg)
  setWindowTitle("Tilengine on Nim")
  createWindow(scale = 2, flags = {cwfNoVsync})
  setTargetFps(60)
  while processWindow():
    drawFrame(0)

main()