import tilengine
import engine
import raylib
import vectors
import private/context as pctx

type
  Window* = object
  WindowPlayers* = object

  WindowFlags* {.size: 4.} = enum
    Fullscreen = 2,       ## Set to run program in fullscreen
    Resizeable = 4,      ## Set to allow resizable window
    Undecorated = 8,    ## Set to disable window decoration (frame and buttons)
    Transparent = 16,   ## Set to allow transparent framebuffer
    Msaa4x = 32,          ## Set to try enabling MSAA 4X
    Vsync = 64,           ## Set to try enabling V-Sync on GPU
    Hidden = 128,       ## Set to hide window
    AlwaysRun = 256,    ## Set to allow windows running while minimized
    Minimized = 512,    ## Set to minimize window (iconify)
    Maximized = 1024,   ## Set to maximize window (expanded to monitor)
    Unfocused = 2048,   ## Set to window non focused
    Topmost = 4096,     ## Set to window always on top
    Highdpi = 8192,     ## Set to support HighDPI
    MousePassthrough = 16384, ## Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    Borderless = 32768, ## Set to run program in borderless windowed mode
    Interlaced = 65536

  Input* = enum
    UP, DOWN, LEFT, RIGHT,
    A, B, X, Y
    L, R,
    START, SELECT

  Mouse* = enum
    LEFT_CLICK, RIGHT_CLICK, MIDDLE_CLICK

var inputsArr = [
  raylib.Up,
  raylib.Down,
  raylib.KeyboardKey.Left,
  raylib.KeyboardKey.Right,
  raylib.W,
  raylib.A,
  raylib.S,
  raylib.D,
  raylib.Q,
  raylib.E,
  raylib.Enter,
  raylib.LeftControl,
]

proc `pressed`*(input: Input): bool =
  return isKeyPressed(inputsArr[input.uint8])

proc `pressedRepeat`*(input: Input): bool =
  return isKeyPressedRepeat(inputsArr[input.uint8])

proc `down`*(input: Input): bool =
  return isKeyDown(inputsArr[input.uint8])

proc `released`*(input: Input): bool =
  return isKeyReleased(inputsArr[input.uint8])

proc `up`*(input: Input): bool =
  return isKeyUp(inputsArr[input.uint8])

proc `pressed`*(input: Mouse): bool =
  return isMouseButtonPressed(input.MouseButton)

proc `down`*(input: Mouse): bool =
  return isMouseButtonDown(input.MouseButton)

proc `released`*(input: Mouse): bool =
  return isMouseButtonReleased(input.MouseButton)

proc `up`*(input: Mouse): bool =
  return isMouseButtonUp(input.MouseButton)

proc `x`*(_: typedesc[Mouse]): int32 =
  return getMouseX()

proc `y`*(_: typedesc[Mouse]): int32 =
  return getMouseY()

proc `pos`*(_: typedesc[Mouse]): vectors.Vec2 =
  var v = getMousePosition()
  return vec2(v.x, v.y) / ctx.getScale

proc `delta`*(_: typedesc[Mouse]): vectors.Vec2 =
  let v = getMouseDelta()
  return Vec2(v.x, v.y) / ctx.getScale

const blur = """
#version 330

in vec2 fragTexCoord; // Texture coordinates passed from the vertex shader
out vec4 fragColor; // Output color

uniform sampler2D texture0; // Input texture

void main()
{
    vec2 texOffset = vec2(1.0 / 320.0, 0.0); // Adjust according to the texture resolution
    vec4 currentPixel = texture(texture0, fragTexCoord);
    vec4 nextPixel = texture(texture0, fragTexCoord + texOffset);

    // Average the current pixel with the next pixel
    vec4 blurredPixel = (currentPixel + nextPixel) / 2.0;

    fragColor = blurredPixel;
}
"""
var blurShader: Shader

proc `[]`*(players: WindowPlayers; idx: range[0..3]): Player = idx.Player

# proc open*(_: typedesc[Window], overlay: string = "", scale: range[0..5] = 0; flags: set[CreateWindowFlag] = {}, threaded: bool = false) =
#   if(threaded): createWindowThread(overlay, scale, flags)
#   else: createWindow(overlay, scale, flags)

proc open*(_: typedesc[Window], scale: range[0.1f..8f] = 1.0, flags: set[WindowFlags] = {Vsync}, fps: int32 = 60, title: string = "Tilengine Window") =
  initWindow((Context.context().width.float * scale).int32, (Context.context().height.float * scale).int32, title)
  Context.context().setTexture(Context.context().width, Context.context().height)
  var flgs: uint32 = 0
  for f in flags:
    flgs = flgs or f.uint32
  setWindowState(Flags[ConfigFlags](flgs))
  Context.context().targetFps = fps
  Context.context().scale = scale.float
  Context.context().setupSystemShader()
  blurShader = loadShaderFromMemory("", blur)

proc `title=`*(_: typedesc[Window], value: string) = tilengine.setWindowTitle(value.cstring)
# proc `process`*(_: typedesc[Window]): bool = processWindow()
# proc `active`*(_: typedesc[Window]): bool = isWindowActive()
proc `process`*(_: typedesc[Window]): bool =
  not windowShouldClose()

proc `players`*(_: typedesc[Window]): WindowPlayers = WindowPlayers()
proc getInput*(_: typedesc[Window], input: Input): bool = getInput(input)
proc getInput*(player: Player, input: tilengine.Input): bool = tilengine.getInput(player, input)
proc `enableInput=`*(player: Player, value: bool) = tilengine.enableInput(player, value)
proc `inputJoystick=`*(player: Player, value: int) = tilengine.assignInputJoystick(player, value)
proc `inputKey=`*(player: Player, value: (tilengine.Input, uint32)) = tilengine.defineInputKey(player, value[0], value[1])
proc `inputKey=`*(player: Player, value: tuple[input: tilengine.Input, keycode: uint32]) = tilengine.defineInputKey(player, value[0], value[1])
proc `inputButton=`*(player: Player, value: (tilengine.Input, uint8)) = tilengine.defineInputButton(player, value[0], value[1])
proc `inputButton=`*(player: Player, value: tuple[input: tilengine.Input, joyButton: uint8]) = tilengine.defineInputButton(player, value[0], value[1])

# proc draw*(_: typedesc[Window], frame: int = 0) = drawFrame(frame)

proc draw*(_: typedesc[Window], frame: int = 0) =
  var texIdx = 0
  var flip = 1.0
  updateFrame(frame)
  # beginDrawing()
  var a = cast[ptr seq[raylib.Color]](Context.context.getFb())
  updateTexture[raylib.Color](cast[Texture2D](Context.context.getTextures()[texIdx].texture), a[])

  beginTextureMode(Context.context.getTextures()[texIdx xor 1])
  beginShaderMode(Context.context.getSystemShader()[])
  drawTexture(Context.context.getTextures()[texIdx].texture, Vector2(x: 0, y: 0), 0, 1, Color(r: 255, g: 255, b: 255, a: 255))
  endShaderMode()
  endTextureMode()

  texIdx = texIdx xor 1
  flip *= -1.0

  setTextureFilter(Context.context.getTextures()[texIdx].texture, Bilinear)
  drawing:
    let winSize = Vector2(x: getScreenWidth().float32, y: getScreenHeight().float32)
    clearBackground(White)  # Set background color
    beginShaderMode(blurShader)
    drawTexture(Context.context.getTextures()[texIdx].texture, raylib.Rectangle(x: 0, y: 0, width: Context.context.getHres().float32, height: Context.context.getVres().float32 * flip), raylib.Rectangle(x: 0,y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32), Vector2(), 0, Color(r: 255, g: 255, b: 255, a: 255))
    endShaderMode()
    drawTexture(Context.context.getMasks()[0], raylib.Rectangle(x: 0, y: 0, width: 1.0, height: Context.context.getVres().float32 * 2), raylib.Rectangle(x: 0,y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32), Vector2(), 0, Color(r: 255, g: 255, b: 255, a: 127))
  setTextureFilter(Context.context.getTextures()[texIdx].texture, Point)

proc waitRedraw*(_: typedesc[Window]) = waitRedraw()
proc close*(_: typedesc[Window]) = deleteWindow()

proc `blur=`*(_: typedesc[Window], value: bool) = enableBlur(value)
proc `crt=`*(_: typedesc[Window], value: (CrtEffect, bool)) = configCrtEffect(value[0], value[1])
proc `crt=`*(_: typedesc[Window], value: tuple[kind: CrtEffect, blur: bool]) = configCrtEffect(value[0], value[1])

proc enableCrtEffect(_: typedesc[Window], overlay: int; overlayFactor: uint8; threshold: uint8; v0, v1, v2, v3: uint8; blur: bool; glowFactor: uint8) =
  enableCrtEffect(overlay, overlayFactor, threshold, v0, v1, v2, v3, blur, glowFactor)

proc disableCrt*(_: typedesc[Window]) = disableCrtEffect()
# TODO : Implement SDL Callback
proc delay*(_: typedesc[Window], msecs: Natural) = delay(msecs)
proc `ticks`*(_: typedesc[Window]): int = getTicks()
proc `width`*(_: typedesc[Window]): int = getWindowWidth()
proc `height`*(_: typedesc[Window]): int = getWindowHeight()
proc `scale`*(_: typedesc[Window]): int = getWindowScaleFactor()
proc `scale=`*(_: typedesc[Window], value: int) = setWindowScaleFactor(value)

# export tilengine.CreateWindowFlag
# export tilengine.Input
export tilengine.Player
export tilengine.CrtEffect
