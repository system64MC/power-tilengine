import tilengine
import private/tilemap as ptmap
import private/palette as ppal
import private/context as pctx
import private/bitmap as pbmap
import exceptions
import colors
import raylib
import cram

type
  RasterCallback* = proc(line : int32): void
  FrameCallback*  = proc(frame: int32): void
  EnginePalettes* = object
  EngineLayers* = object
  EngineSprites* = object

var rCallback: RasterCallback = nil
var fCallback: FrameCallback  = nil



proc rastCallback(line: int32) {.cdecl.} =
  if(rCallback != nil): rCallback(line)

proc frameCallback(frame: int32): void {.cdecl.} =
  if(fCallback != nil): fCallback(frame)

proc init*(_: typedesc[Context], hres, vres: SomeInteger, numLayers: SomeInteger = 4, numSprites: SomeInteger = 64, numAnimations: SomeInteger = 64, palLength: SomeInteger = 16): Context =
  ## Creates the Tilengine context.
  result = newContext(
    init(hres, vres, numLayers, numSprites, numAnimations),
    hres.int,
    vres.int,
    numLayers.int,
    numSprites.int,
    numAnimations.int,
    getTargetFps(),
    palLength.int
  )

  setRenderTarget(cast[ptr UncheckedArray[uint8]](result.getFb[][0].addr), hres * 4)

  setRasterCallback(rastCallback)
  setFrameCallback(frameCallback)
  ctx = result

func deinit*(_: typedesc[Context]) = tilengine.deinit()
func delete*(engine: Context) = 
  deleteContext(engine.getContext())
  engine.setContext(nil)

proc `context`*(_: typedesc[Context]): Context = 
  ## Get the context.
  ctx

proc `context=`*(_: typedesc[Context], value: Context) = 
  ## Sets the context.
  ctx = value
  setContext(value.getContext())

func `targetFps`*(engine: Context): int = 
  ## Get the targeted framerate.
  engine.getFps()

proc `targetFps=`*(engine: Context, value: SomeInteger) = 
  ## Sets the targeted framerate.
  tilengine.setTargetFps(value.int)
  engine.setFps(value)
  raylib.setTargetFps(value.int32)

func `width`*(engine: Context): int = 
  ## Get context horizontal resolution
  engine.getHres()

func `height`*(engine: Context): int = 
  ## Get context vertical resolution
  engine.getVres()

func `scale`*(engine: Context): float32 = 
  engine.getScale()

func `scale=`*(engine: Context, scale: SomeFloat) = 
  engine.setScale(scale)

func `numObjects`*(engine: Context): int = 
  ## Get number of usable objects.
  getNumObjects()
  
func `numSprites`*(engine: Context): int = 
  ## Get number of usable sprites.
  engine.getNumSprites()

func `numAnimations`*(engine: Context): int = 
  ## Get number of usable animations.
  engine.getNumAnimations()

func `numLayers`*(engine: Context): int = 
  ## Get number of availlable layers.
  engine.getNumLayers()

func `usedMemory`*(engine: Context): int = 
  ## Get amount of used memory.
  getUsedMemory()

func `version`*(engine: Context): (int, int, int) = 
  ## Get Tilengine version.
  getVersion()

func `bgColor=`*(engine: Context, value: colors.Color) = 
  ## Sets the background color
  setBgColor(value.r, value.g, value.b)

func `bgColorTilemap=`*(engine: Context, value: ptmap.Tilemap) = 
  ## Sets the background color from a Tilemap.
  setBgColorFromTilemap(value.getData())


func disableBgColor*(engine: Context) = 
  ## Disables the background color.
  disableBgColor()

func `bgBitmap=`*(_: Context, value: pbmap.Bitmap) = 
  if(value.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  setBgBitmap(value.getData())

func `bgPalette=`*(ctx: Context, value: SomeInteger) = 
  setBgPalette(ctx.cram.getTlnPalette(value))

# func `palettes`*(_: Context): EnginePalettes = EnginePalettes()
# func `[]`*(pals: EnginePalettes; idx: range[0..7]): ppal.Palette = newPalette(getGlobalPalette(idx), true)
# func `[]=`*(pals: EnginePalettes; idx: range[0..7], value: ppal.Palette) = setGlobalPalette(idx, value.getData())

proc `rasterCallback=`*(engine: Context, value: RasterCallback) = 
  ## Sets the raster callback procedure.
  rCallback = value

proc `frameCallback=`* (engine: Context, value: FrameCallback ) = 
  ## Sets the frame callback procedure.
  fCallback = value

proc `blendFunction=`* (engine: Context, value: BlendFunction) = setCustomBlendFunction(value)

func setRenderTarget* (engine: Context, value: openArray[uint8], pitch: int) = 
  ## Sets the render target.
  ## useful if you want to render to a texture or as a picture.
  setRenderTarget(cast[ptr UncheckedArray[uint8]](value[0].addr), pitch)

func updateFrame*(engine: Context, frame: int) = 
  ## Updates the frame. To be used with setRenderTarget()
  updateFrame(frame)

func `loadPath=`*(engine: Context, value: string) = 
  ## Sets the loading path.
  setLoadPath(value.cstring)

func `logLevel=`*(engine: Context, value: LogLevel) = 
  ## Sets the logging level. Availlable are : logNone, logErrors and logVerbose.
  setLogLevel(value)

func openResourcePack*(engine: Context, value: string, key: string = "") = 
  ## Opens a resource pack.
  ## Key is needed in case where assets are encrypted.
  openResourcePack(value.cstring, if(key == ""): nil else: key.cstring)

func closeResourcePack*(engine: Context) = 
  ## Closes the resource packs.
  closeResourcePack()

func `layers`*(engine: Context): EngineLayers = 
  ## Accessor for layers.
  ## It allows for a syntax like this :
  ## myContext.layers[someIndex]
  EngineLayers()

func `sprites`*(engine: Context): EngineSprites = EngineSprites()

func `cram`*(engine: Context): ColorRAM =
  engine.getCram()

func `[]`*(lays: EngineLayers; idx: SomeInteger): Layer = Layer(idx)
func `[]`*(lays: EngineSprites; idx: SomeInteger): Sprite = Sprite(idx)

export tilengine.BlendFunction
export tilengine.LogLevel
export pctx.Context
# export tilengine.Engine