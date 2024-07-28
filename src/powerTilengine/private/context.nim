import tilengine
import tilemap as ptmap
import palette as ppal
import cram as pcram
import colors
import raylib

type
  EngineImpl* = object
    tlnContext: tilengine.Engine
    hres: int
    vres: int
    scale: float32
    numLayers: int
    numSprites: int
    numAnimations: int
    targetFps: int
    cram: ColorRAM
    fBuffer: seq[colors.Color]
    textures: array[2, RenderTexture2d] # 3th texture is crt mask
    crtMasks: array[1, Texture2D]
    systemShader: Shader

  Context* = ref EngineImpl

proc `=destroy`(context: EngineImpl): void =
  for i in 0..context.numLayers:
    case Layer(i).getType():
    of LayerTile:
      let tmap = Layer(i).getTilemap()
      if(tmap != nil): tmap.delete()
    of LayerBitmap: 
      let bmap = Layer(i).getBitmap()
      if(bmap != nil): bmap.delete()
    of LayerObject: 
      let objs = Layer(i).getObjects()
      if(objs != nil): objs.delete()
    of LayerNone: continue
  tilengine.deinit()
  closeWindow()

proc getContext*(ctx: Context): tilengine.Engine = ctx.tlnContext
proc setContext*(ctx: Context, value: tilengine.Engine) = 
  ctx.tlnContext = value

proc getFb*(ctx: Context): ptr seq[colors.Color] = ctx.fBuffer.addr
proc getTextures*(ctx: Context): ptr UncheckedArray[RenderTexture2d] = cast[ptr UncheckedArray[RenderTexture2d]](ctx.textures[0].addr)
proc getMasks*(ctx: Context): ptr UncheckedArray[Texture2D] = cast[ptr UncheckedArray[Texture2D]](ctx.crtMasks[0].addr)
proc setTexture*(ctx: Context, hres, vres: int) =
  ctx.textures[0] = loadRenderTexture(hres.int32, vres.int32)
  ctx.textures[1] = loadRenderTexture(hres.int32, vres.int32)
  var img = genImageColor(1, vres.int32 * 2, raylib.Color(r: 0, g: 0, b: 0, a: 0))
  let dat = cast[ptr UncheckedArray[raylib.Color]](img.data)
  for i in 0..<vres:
    dat[i shl 1] = raylib.Color(r: 0, g: 0, b: 0, a: 255)

  ctx.crtMasks[0] = loadTextureFromImage(img)
  setTextureFilter(ctx.crtMasks[0], Bilinear)

proc getFps*(ctx: Context): int = ctx.targetFps
proc setFps*(ctx: Context, value: SomeInteger) = 
  ctx.targetFps = value.int

proc getScale*(ctx: Context): float32 = ctx.scale
proc setScale*(ctx: Context, value: SomeFloat) = 
  ctx.scale = value.float32

proc getHres*(ctx: Context): int = ctx.hres
proc getVres*(ctx: Context): int = ctx.vres
proc getNumLayers*(ctx: Context): int = ctx.numLayers
proc getNumSprites*(ctx: Context): int = ctx.numSprites
proc getNumAnimations*(ctx: Context): int = ctx.numAnimations
proc getCram*(ctx: Context): ColorRAM = ctx.cram

const systemShader = """
#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables

void main()
{
    // Texel color fetching from texture sampler
    vec4 texelColor = texture(texture0, fragTexCoord)*colDiffuse*fragColor;
    finalColor = vec4(texelColor.b, texelColor.g, texelColor.r, texelColor.a);
}"""

proc newContext*(ctx: tilengine.Engine, hres, vres, numLayers, numSprites, numAnimations, targetFps, palLength: int): Context =
  Context(
    tlnContext: ctx,
    hres: hres,
    vres: vres,
    numLayers: numLayers,
    numSprites: numSprites,
    numAnimations: numAnimations,
    targetFps: targetFps,
    fBuffer: newSeq[colors.Color](hres * vres),
    cram: newCram(palLength)
  )

proc setupSystemShader*(ctx: Context) =
  ctx.systemShader = loadShaderFromMemory("", systemShader)

proc getSystemShader*(ctx: Context): ptr Shader =
  ctx.systemShader.addr

var ctx*: Context