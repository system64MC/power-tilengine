import tilengine
import engine
import raylib
import vectors
import private/context as pctx
import colors as cols

type
  Primitive = enum
    TEXT,
    LINE,
    RECTANGLE,
    CIRCLE,
    TRIANGLE

  PrimitiveDraw = object
    case kind: Primitive
    of TEXT:
      text: string
      textPos: Vec2
      textSize: float
      spacing: float
      textColor: cols.Color
    of LINE:
      startPos: Vec2
      endPos: Vec2
      thick: float
      lineColor: cols.Color
    of RECTANGLE:
      rectPos: Vec2
      rectSize: Vec2
      rectColor: cols.Color
      rectangleFill: bool
      rectangleThick: float
    of CIRCLE:
      circPos: Vec2
      radius: float
      circColor: cols.Color
      circleFill: bool
    of TRIANGLE:
      v1: Vec2
      v2: Vec2
      v3: Vec2
      triColor: cols.Color
      triangleFill: bool

  PrimitiveStack = object
    primStack: array[4096, PrimitiveDraw]
    sp: uint16

  Window* = ref object
    primStack: PrimitiveStack
    crt*: bool

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

  InputButton* = enum
    UP, DOWN, LEFT, RIGHT,
    A, B, X, Y
    L, R,
    START, SELECT, CRT

  Mouse* = enum
    LEFT_CLICK, RIGHT_CLICK, MIDDLE_CLICK

  Axis* = enum
    NULL = -1,
    LEFT_X = 0,
    LEFT_Y = 1,
    RIGHT_X = 2,
    RIGHT_Y = 3,
    LEFT_TRIG = 4,
    RIGHT_TRIG = 5,

  Input* = object
    key: KeyboardKey
    padButton: GamepadButton
    axis: Axis
    direction: float


  InputsObject* = object
    inputs: array[InputButton, Input] = [
      Input(key: KeyboardKey.Up, padButton: GamepadButton.LeftFaceUp, axis: LEFT_Y, direction: -1.0),
      Input(key: KeyboardKey.Down, padButton: GamepadButton.LeftFaceDown, axis: LEFT_Y, direction: 1.0),
      Input(key: KeyboardKey.Left, padButton: GamepadButton.LeftFaceLeft, axis: LEFT_X, direction: -1.0),
      Input(key: KeyboardKey.Right, padButton: GamepadButton.LeftFaceRight, axis: LEFT_X, direction: 1.0),

      Input(key: KeyboardKey.W, padButton: GamepadButton.RightFaceRight, axis: NULL, direction: 1.0),
      Input(key: KeyboardKey.A, padButton: GamepadButton.RightFaceDown, axis: NULL, direction: 1.0),
      Input(key: KeyboardKey.S, padButton: GamepadButton.RightFaceUp, axis: NULL, direction: 1.0),
      Input(key: KeyboardKey.D, padButton: GamepadButton.RightFaceLeft, axis: NULL, direction: 1.0),

      Input(key: KeyboardKey.Q, padButton: GamepadButton.LeftTrigger1, axis: LEFT_TRIG, direction: 1.0),
      Input(key: KeyboardKey.E, padButton: GamepadButton.RightTrigger1, axis: RIGHT_TRIG, direction: 1.0),

      Input(key: KeyboardKey.Enter, padButton: GamepadButton.MiddleRight, axis: NULL, direction: 1.0),
      Input(key: KeyboardKey.LeftControl, padButton: GamepadButton.MiddleLeft, axis: NULL, direction: 1.0),
      Input(key: KeyboardKey.Backspace, padButton: GamepadButton.Middle, axis: NULL, direction: 1.0),
    ]
    gamepadId: int32
    axisThreshold: float = 0.5
    previousAxis: array[6, float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    currentAxis: array[6, float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]


var globalInputs = InputsObject()

proc isAxisDown*(input: InputButton): bool =
  let x = if(globalInputs.inputs[input].axis == NULL): 0.0 else: globalInputs.currentAxis[globalInputs.inputs[input].axis.uint8]
  return ((
    if(x == 0.0): 0.0 else: x / abs(x)
  ) == globalInputs.inputs[input].direction and abs(x) >= globalInputs.axisThreshold)

proc `wasAxisDown`*(input: InputButton): bool =
  let x = if(globalInputs.inputs[input].axis == NULL): 0.0 else: globalInputs.previousAxis[globalInputs.inputs[input].axis.uint8]
  return ((
    if(x == 0.0): 0.0 else: x / abs(x)
  ) == globalInputs.inputs[input].direction and abs(x) >= globalInputs.axisThreshold)

proc `pressed`*(input: InputButton): bool =
  let wasNotDown = not wasAxisDown(input)
  let isDown = isAxisDown(input)
  return isKeyPressed(globalInputs.inputs[input].key) or
  isGamepadButtonPressed(globalInputs.gamepadId, globalInputs.inputs[input].padButton) or
  (isDown and wasNotDown)

proc `down`*(input: InputButton): bool =
  return isKeyDown(globalInputs.inputs[input].key) or
  isGamepadButtonDown(globalInputs.gamepadId, globalInputs.inputs[input].padButton) or
  isAxisDown(input)

proc `released`*(input: InputButton): bool =
  let wasDown = wasAxisDown(input)
  let isDown = isAxisDown(input)
  return isKeyReleased(globalInputs.inputs[input].key) or
  isGamepadButtonReleased(globalInputs.gamepadId, globalInputs.inputs[input].padButton) or
  ((not isDown) and wasDown)

proc `up`*(input: InputButton): bool =
  return isKeyUp(globalInputs.inputs[input].key) and
  isGamepadButtonUp(globalInputs.gamepadId, globalInputs.inputs[input].padButton) and
  (not isAxisDown(input))

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

#proc setKeyboardKey*(key: InputButton) =
#  let i = raylib.getKeyPressed()
#  if(i == Null): return
#  globalInputs.keyboardArr[key] = i

#proc setGamepadKey*(key: InputButton) =
#  let i = raylib.getGamepadButtonPressed()
#  if(i == Unknown): return
#  globalInputs.gamepadArr[key] = i

#proc getGamepadKey*(): GamepadButton =
#  return raylib.getGamepadButtonPressed()

proc getGamepadAxisMovement*(axis: Axis): float =
  return raylib.getGamepadAxisMovement(globalInputs.gamepadId, axis.GamepadAxis)

proc getLeftJoyMovement*(): vectors.Vec2 =
  return vec2(
    raylib.getGamepadAxisMovement(globalInputs.gamepadId, LEFT_X.GamepadAxis),
    raylib.getGamepadAxisMovement(globalInputs.gamepadId, LEFT_Y.GamepadAxis)
  )

proc `pos`*(_: typedesc[Mouse]): vectors.Vec2 =
  var v = getMousePosition()
  var rx = ctx.getHres().float / getScreenWidth().float
  var ry = ctx.getVres().float / getScreenHeight().float

  return vec2(v.x * rx, v.y * ry)

proc `realPos`*(_: typedesc[Mouse]): vectors.Vec2 =
  let v = getMousePosition()
  return vec2(v.x, v.y)

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

proc open*(_: typedesc[Window], scale: range[0.1f..8f] = 1.0, flags: set[WindowFlags] = {Vsync}, fps: int32 = 60, title: string = "Tilengine Window", crt: bool = false): Window =
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
  result = new Window
  result.crt = crt

proc `title=`*(_: Window, value: string) =
  raylib.setWindowTitle(value.cstring)

proc `process`*(window: Window): bool =
  if(CRT.pressed): window.crt = not window.crt
  result = not windowShouldClose()
  for i in 0..<6:
    globalInputs.previousAxis[i] = globalInputs.currentAxis[i]
  globalInputs.currentAxis[LEFT_X.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, LEFT_X.GamepadAxis)
  globalInputs.currentAxis[LEFT_Y.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, LEFT_Y.GamepadAxis)
  globalInputs.currentAxis[RIGHT_X.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, RIGHT_X.GamepadAxis)
  globalInputs.currentAxis[RIGHT_Y.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, RIGHT_Y.GamepadAxis)
  globalInputs.currentAxis[LEFT_TRIG.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, LEFT_TRIG.GamepadAxis)
  globalInputs.currentAxis[RIGHT_TRIG.uint8] = raylib.getGamepadAxisMovement(globalInputs.gamepadId, RIGHT_TRIG.GamepadAxis)

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

proc drawPrimitives(window: Window) =
  for i in 0u16..<window.primStack.sp:
    case window.primStack.primStack[i].kind:
      of TEXT:
        drawText(getFontDefault(),
          window.primStack.primStack[i].text.cstring,
          raylib.Vector2(x: window.primStack.primStack[i].textPos.x, y: window.primStack.primStack[i].textPos.y),
          window.primStack.primStack[i].textSize.float32,
          window.primStack.primStack[i].spacing.float32,
          raylib.Color(r: window.primStack.primStack[i].textColor.r, g: window.primStack.primStack[i].textColor.g, b: window.primStack.primStack[i].textColor.b, a: 255))
      else:
        continue


proc draw*(window: Window, frame: int = 0) =
  var texIdx = 0
  var flip = 1.0
  updateFrame(frame)
  # beginDrawing()
  var a = cast[ptr seq[raylib.Color]](Context.context.getFb())
  updateTexture[raylib.Color](cast[Texture2D](Context.context.getTextures()[texIdx].texture), a[])

  beginTextureMode(Context.context.getTextures()[texIdx xor 1])
  beginShaderMode(Context.context.getSystemShader()[])
  drawTexture(Context.context.getTextures()[texIdx].texture, Vector2(x: 0, y: 0), 0, 1, raylib.Color(r: 255, g: 255, b: 255, a: 255))
  endShaderMode()
  endTextureMode()

  texIdx = texIdx xor 1
  flip *= -1.0
  if(window.crt):
    setTextureFilter(Context.context.getTextures()[texIdx].texture, Bilinear)
    drawing:
      let winSize = Vector2(x: getScreenWidth().float32, y: getScreenHeight().float32)
      clearBackground(White)  # Set background color
      beginShaderMode(blurShader)
      drawTexture(Context.context.getTextures()[texIdx].texture, raylib.Rectangle(x: 0, y: 0, width: Context.context.getHres().float32, height: Context.context.getVres().float32 * flip), raylib.Rectangle(x: 0,y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32), Vector2(), 0, raylib.Color(r: 255, g: 255, b: 255, a: 255))
      endShaderMode()
      drawTexture(Context.context.getMasks()[0], raylib.Rectangle(x: 0, y: 0, width: 1.0, height: Context.context.getVres().float32 * 2), raylib.Rectangle(x: 0,y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32), Vector2(), 0, raylib.Color(r: 255, g: 255, b: 255, a: 127))
      window.drawPrimitives()
      window.primStack.sp = 0
    setTextureFilter(Context.context.getTextures()[texIdx].texture, Point)
  else:
    setTextureFilter(Context.context.getTextures()[texIdx].texture, Point)
    drawing:
      let winSize = Vector2(x: getScreenWidth().float32, y: getScreenHeight().float32)
      clearBackground(White)  # Set background color
      drawTexture(Context.context.getTextures()[texIdx].texture, raylib.Rectangle(x: 0, y: 0, width: Context.context.getHres().float32, height: Context.context.getVres().float32 * flip), raylib.Rectangle(x: 0,y: 0, width: getScreenWidth().float32, height: getScreenHeight().float32), Vector2(), 0, raylib.Color(r: 255, g: 255, b: 255, a: 255))
      window.drawPrimitives()
      window.primStack.sp = 0

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
proc `width`*(w: Window): int = getScreenWidth()
proc `height`*(w: Window): int = getScreenHeight()
proc `dims`*(w: Window): Vec2 = vec2(getScreenWidth().float, getScreenHeight().float)
proc `dims=`*(w: Window, value: Vec2) = setWindowSize(value.x.int32, value.y.int32)
proc `fbWidth`*(w: Window): int = tilengine.getWidth()
proc `fbHeight`*(w: Window): int = tilengine.getHeight()
proc `fbDims`*(w: Window): Vec2 = vec2(tilengine.getWidth().float, tilengine.getHeight().float)
proc `scale`*(w: Window): Vec2 = w.dims / w.fbDims
proc `scale=`*(w: Window, value: Vec2) =
  let tmp = w.fbDims * value
  setWindowSize(tmp.x.int32, tmp.y.int32)

proc `scale=`*(w: Window, value: SomeNumber) =
  let tmp = w.fbDims * value.float
  setWindowSize(tmp.x.int32, tmp.y.int32)

proc `deltatime`*(): float =
  getFrameTime()

proc `cursorVisible=`*(window: Window, value: bool) =
  if(value): raylib.showCursor() else: raylib.hideCursor()

proc drawText*(window: Window, text: string, position: Vec2, size: SomeNumber = 20, spacing: SomeNumber = 3, color: cols.Color = color(255, 255, 255)) =
  window.primStack.primStack[window.primStack.sp] = PrimitiveDraw(kind: TEXT, text: text, textPos: position, textSize: size.float, spacing: spacing.float, textColor: color)
  window.primStack.sp.inc()

# export tilengine.CreateWindowFlag
# export tilengine.Input
# export tilengine.Player
# export tilengine.CrtEffect
