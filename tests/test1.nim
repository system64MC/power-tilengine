import ../src/powerTilengine/[
  engine, window, layers, tilemaps, colors, bitmaps, palettes, tilesets,
  cram, spritesets, sprites,
  vectors, math,
  sugar
]

when isMainModule:
  let ctx = Context.init(320, 224, palLength = 24)
  var myPos = vec2(0.0, 0.0)
  ctx.loadPath = "./assets"
  let foreground = Bitmap.load("elis2.png")
  ctx.cram[1] = foreground.palette

  # Loading sprite and set palette
  let sp = Spriteset.load("smw/smw_sprite.png")
  ctx.sprites[0].spriteset = sp
  ctx.cram[8] = sp.palette
  ctx.sprites[0].palette = 8

  ctx.layers[0].bitmap = foreground
  foreground.palette = 1
  ctx.layers[1].tilemap = Tilemap.load("sonic/Sonic_md_bg1.tmx")
  ctx.cram[0] = ctx.layers[1].tilemap.tilesets[0].palette
  var frame = 0.0
  var ticks = 0
  ctx.rasterCallback = ((ln: int32) -> void) => (
    ctx.layers[0].posX = sin((ln.float + frame) / 8.0) * 4.0;
    ctx.bgColor = lerp(color(20, 25, 255), color(0, 120, 20), (ln.float / 223))
                  .convertAndCopy(ColorConverter.Amiga);
  )
  Window.title = "Tilengine with Nim"
  Window.open(scale = 2, flags = {Vsync, Resizeable})

  ctx.layers[0].enable = true
  ctx.layers[1].enable = true

  while Window.process:
    if(Input.RIGHT.down): myPos.x += 2.0
    if(Input.LEFT.down): myPos.x -= 2.0
    if(Input.UP.down): myPos.y -= 2.0
    if(Input.DOWN.down): myPos.y += 2.0
    if(Mouse.LEFT_CLICK.pressed):
      myPos = Mouse.pos
    if(Mouse.RIGHT_CLICK.pressed):
      myPos = vec2(0)
    ctx.sprites[0].position = myPos
    Window.draw()
    frame += 0.2
    if(ticks & 0x3F == 0x3F): Layer(0).swap(Layer(1))
    ticks.inc
