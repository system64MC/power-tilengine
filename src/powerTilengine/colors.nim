import math

type
  ColorConverter* = enum
    OneBit ## One bit depth (0-1)
    GameBoy ## 2 bits grayscale (0-3)
    VirtualBoy ## 2 bits red scale (0-3)
    Cpc ## 3 levels per color channel (0-2)
    MasterSystem ## 2 bits per color channel (0-3)
    Rgb332 ## 3 bits for red, 3 bits for green, 2 bits for blue (0-7, 0-7 and 0-3)
    Rgb323 ## 3 bits for red, 2 bits for green, 3 bits for blue (0-7, 0-3 and 0-7)
    Rgb233 ## 2 bits for red, 3 bits for green, 3 bits for blue (0-3, 0-7 and 0-7)
    Genesis224 ## 3 bits per color channel, 32 steps per level (0-7)
    Genesis252 ## 3 bits per color channel, 36 steps per level (0-7)
    Genesis255 ## 3 bits per color channel, covers full range (0-7)
    GenesisHardware ## 3 bits per color channel, accurate to hardware
    Amiga ## 4 bits per color channel (0-F)
    Snes ## 5 bits per color channel (0-1F)
    Rgb326432 ## 16 bits rgb : 5 for red, 6 for green, 5 for blue (0-1F, 0-3F and 0-1F)
    Ds ## 18 bits rgb, 6 for red, 6 for green, 6 for blue (0-3F, 0-3F and 0-3F)
    Grayscale ## 8-bits grayscale
    None ## Do not convert

  Color* = object
    b*: uint8
    g*: uint8
    r*: uint8
    a*: uint8

func color*(r, g, b: uint8): Color =
  Color(r: r, g: g, b: b)

proc `+`*(color1: Color, color2: Color): Color {.inline.} =
  ## Adds 2 colors together.
  Color(
    r: min(color1.r.uint16 + color2.r.uint16, 255).uint8,
    g: min(color1.g.uint16 + color2.g.uint16, 255).uint8,
    b: min(color1.b.uint16 + color2.b.uint16, 255).uint8,
    )

proc `-`*(color1: Color, color2: Color): Color {.inline.} =
  ## Subtracts color 2 from color 1.
  Color(
    r: max(color1.r.int16 - color2.r.int16, 0).uint8,
    g: max(color1.g.int16 - color2.g.int16, 0).uint8,
    b: max(color1.b.int16 - color2.b.int16, 0).uint8,
    )

proc `*`*(color1: Color, color2: Color): Color {.inline.} =
  ## Normalized product between 2 colors.
  Color(
    r: min((color1.r.uint16 * color2.r.uint16) div 255, 255).uint8,
    g: min((color1.g.uint16 * color2.g.uint16) div 255, 255).uint8,
    b: min((color1.b.uint16 * color2.b.uint16) div 255, 255).uint8,
    )

proc `+=`*(color1: var Color, color2: Color) {.inline.} =
  ## Add and self assignment.
  color1.r = min(color1.r.uint16 + color2.r.uint16, 255).uint8
  color1.g = min(color1.g.uint16 + color2.g.uint16, 255).uint8
  color1.b = min(color1.b.uint16 + color2.b.uint16, 255).uint8

proc `-=`*(color1: var Color, color2: Color) {.inline.} =
  ## Subtract and self assignment.
  color1.r = max(color1.r.int16 - color2.r.int16, 0).uint8
  color1.g = max(color1.g.int16 - color2.g.int16, 0).uint8
  color1.b = max(color1.b.int16 - color2.b.int16, 0).uint8

proc `*=`*(color1: var Color, color2: Color) {.inline.} =
  ## Normalized product and self assignment.
  color1.r = min((color1.r.uint16 * color2.r.uint16) div 255, 255).uint8
  color1.g = min((color1.g.uint16 * color2.g.uint16) div 255, 255).uint8
  color1.b = min((color1.b.uint16 * color2.b.uint16) div 255, 255).uint8

proc amigafy(color: var Color) {.inline.} =
  ## Converts an RGB value into an amiga color.
  color.r = (color.r and 0xF0) or (color.r shr 4)
  color.g = (color.g and 0xF0) or (color.g shr 4)
  color.b = (color.b and 0xF0) or (color.b shr 4)

proc smsify(color: var Color) {.inline.} =
  ## Converts an RGB value into a Sega Master System color.
  color.r = (color.r shr 6) or ((color.r shr 6) shl 2) or ((color.r shr 6) shl 4) or ((color.r and 0b11_000000))
  color.g = (color.g shr 6) or ((color.g shr 6) shl 2) or ((color.g shr 6) shl 4) or ((color.g and 0b11_000000))
  color.b = (color.b shr 6) or ((color.b shr 6) shl 2) or ((color.b shr 6) shl 4) or ((color.b and 0b11_000000))

proc genesisify224(color: var Color) {.inline.} =
  ## Converts an RGB value into a Sega Genesis color, max is 224.
  color.r = (color.r and 0b111_00000)
  color.g = (color.g and 0b111_00000)
  color.b = (color.b and 0b111_00000)

proc genesisify252(color: var Color) {.inline.} =
  ## Converts an RGB value into a Sega Genesis color, max is 252.
  color.r = (color.r div 36) * 36
  color.g = (color.g div 36) * 36
  color.b = (color.b div 36) * 36

proc genesisify255(color: var Color) {.inline.} =
  ## Converts an RGB value into a Sega Genesis color, covers the full range.
  color.r = floor((color.r shr 5).float * 36.5).uint8
  color.g = floor((color.g shr 5).float * 36.5).uint8
  color.b = floor((color.b shr 5).float * 36.5).uint8

const genesisValues: array[8, uint8] = [0, 52, 87, 116, 144, 172, 206, 255]
proc genesisifyHardware(color: var Color) {.inline.} =
  ## Converts an RGB value into a Sega Genesis color, hardware accurate.
  color.r = genesisValues[color.r shr 5]
  color.g = genesisValues[color.g shr 5]
  color.b = genesisValues[color.b shr 5]


proc snesify(color: var Color) {.inline.} =
  ## Converts an RGB value into a SNES color.
  color.r = (color.r and 0b11111_000)
  color.g = (color.g and 0b11111_000)
  color.b = (color.b and 0b11111_000)

proc dsify(color: var Color) {.inline.} =
  ## Converts an RGB value into a DS color.
  color.r = (color.r and 0b111111_00)
  color.g = (color.g and 0b111111_00)
  color.b = (color.b and 0b111111_00)

proc msxify(color: var Color) {.inline.} =
  ## Converts an RGB value into an MSX color.
  let b: uint8 = color.b and 0b11_000000
  color.r = floor((color.r shr 5).float * 36.5).uint8
  color.g = floor((color.g shr 5).float * 36.5).uint8
  color.b = (b shr 6) or (b shr 4) or (b shr 2) or (b)

proc rgb323ify(color: var Color) {.inline.} =
  ## Converts an RGB value into an MSX color.
  let g: uint8 = color.g and 0b11_000000
  color.r = floor((color.r shr 5).float * 36.5).uint8
  color.g = (g shr 6) or (g shr 4) or (g shr 2) or (g)
  color.b = floor((color.b shr 5).float * 36.5).uint8

proc rgb233ify(color: var Color) {.inline.} =
  ## Converts an RGB value into an MSX color.
  let r: uint8 = color.r and 0b11_000000
  color.r = (r shr 6) or (r shr 4) or (r shr 2) or (r)
  color.g = floor((color.g shr 5).float * 36.5).uint8
  color.b = floor((color.b shr 5).float * 36.5).uint8

proc onebitify(color: var Color) {.inline.} =
  ## Convers an RGB value into a 1-bit color.
  color.r = if(color.r > 0x7F): 0xFF else: 0x0
  color.g = if(color.g > 0x7F): 0xFF else: 0x0
  color.b = if(color.b > 0x7F): 0xFF else: 0x0

proc gameboyify(color: var Color) {.inline.} =
  ## Converts an RGB value to GameBoy grayscale.
  var val = ((color.r.uint16 + color.g.uint16 + color.b.uint16) div 3).uint8 and 0b11_000000
  val = val or (val shr 2) or (val shr 4) or (val shr 6)
  color.r = val
  color.g = val
  color.b = val

proc virtualboyify(color: var Color) {.inline.} =
  ## Converts an RGB value to GameBoy grayscale.
  var val = ((color.r.uint16 + color.g.uint16 + color.b.uint16) div 3).uint8 and 0b11_000000
  val = val or (val shr 2) or (val shr 4) or (val shr 6)
  color.r = val
  color.g = 0
  color.b = 0

proc cpcify(color: var Color) {.inline.} =
  ## Converts an RGB value into an Amstrad CPC color.
  color.r = floor(round(color.r.float / 127.5).float * 127.5).uint8
  color.g = floor(round(color.g.float / 127.5).float * 127.5).uint8
  color.b = floor(round(color.b.float / 127.5).float * 127.5).uint8

proc rgb32_64_32_ify(color: var Color) {.inline.} =
  color.r = (color.r and 0b11111_000)
  color.g = (color.g and 0b11111_100)
  color.b = (color.b and 0b11111_000)

proc grayscaleify(color: var Color) {.inline.} =
  var val = ((color.r.uint16 + color.g.uint16 + color.b.uint16) div 3).uint8
  color.r = val
  color.g = val
  color.b = val

proc convert*(color: var Color, convert: ColorConverter) =
  ## Converts a color
  case convert:
  of OneBit: color.onebitify()
  of GameBoy: color.gameboyify()
  of VirtualBoy: color.virtualboyify()
  of Cpc: color.cpcify()
  of MasterSystem: color.smsify()
  of Rgb332: color.msxify()
  of Rgb323: color.rgb323ify()
  of Rgb233: color.rgb233ify()
  of Genesis224: color.genesisify224()
  of Genesis252: color.genesisify252()
  of Genesis255: color.genesisify255()
  of GenesisHardware: color.genesisifyHardware()
  of Amiga: color.amigafy()
  of Snes: color.snesify()
  of Rgb326432: color.rgb32_64_32_ify()
  of Ds: color.dsify()
  of Grayscale: color.grayscaleify()
  of None: discard

proc convertAndCopy*(color: Color, convert: ColorConverter): Color =
  ## Converts a color
  result = color
  case convert:
  of OneBit: result.onebitify()
  of GameBoy: result.gameboyify()
  of VirtualBoy: result.virtualboyify()
  of Cpc: result.cpcify()
  of MasterSystem: result.smsify()
  of Rgb332: result.msxify()
  of Rgb323: result.rgb323ify()
  of Rgb233: result.rgb233ify()
  of Genesis224: result.genesisify224()
  of Genesis252: result.genesisify252()
  of Genesis255: result.genesisify255()
  of GenesisHardware: result.genesisifyHardware()
  of Amiga: result.amigafy()
  of Snes: result.snesify()
  of Rgb326432: result.rgb32_64_32_ify()
  of Ds: result.dsify()
  of Grayscale: result.grayscaleify()
  of None: discard

{.push overflowChecks: off.}
proc invert*(color: var Color) =
  color.r = not color.r
  color.g = not color.g
  color.b = not color.b

proc invertCopy*(color: Color): Color =
  Color(
    r: not color.r,
    g: not color.g,
    b: not color.b
  )
{.pop.}

import strutils
func hex2color*(hex: string): Color =
  cast[Color](fromHex[uint32](hex).uint32)

func toColor*(value: uint32): Color =
  cast[Color](value)

func toColor*(value: uint64): Color =
  cast[Color](value.uint32)

func lerp*(color1: Color, color2: Color, t: SomeFloat): Color =
  Color(
    r: lerp(color1.r, color2.r, t).uint8,
    g: lerp(color1.g, color2.g, t).uint8.uint8,
    b: lerp(color1.b, color2.b, t).uint8.uint8
  )