import tilengine
import palette as ppal
import ../colors
import ../spans

type
  ColorRAMImpl* = object
    palettes: array[16, tilengine.Palette]
    length: int

  ColorRAM* = ref ColorRAMImpl

proc `=destroy`*(cram: ColorRAMImpl) =
  for p in cram.palettes:
    if(p == nil): continue
    p.delete()



proc newCram*(length: int): ColorRAM =
  result = ColorRAM(length: length)
  for i in 0..<8:
    let pal = createPalette(length)
    result.palettes[i] = pal
    for j in 0..<length:
      pal.setColor(j, 0, 0, 0)
    setGlobalPalette(i, pal)
  for i in 8..<16:
    result.palettes[i] = createPalette(length)
    for j in 0..<length:
      result.palettes[i].setColor(j, 0, 0, 0)

proc `[]`*(cram: ColorRAM; palIndex: SomeInteger, colIndex: SomeInteger): Color =
  cast[ptr UncheckedArray[Color]](cram.palettes[palIndex].getData(0)).toOpenArray()[colIndex]

proc `[]=`*(cram: ColorRAM; palIndex: SomeInteger, colIndex: SomeInteger; color: Color) =
  var a = cast[ptr UncheckedArray[Color]](cram.palettes[palIndex].getData(0))
  a.toOpenArray(0, cram.length)[colIndex] = color

proc `[]`*(cram: ColorRAM; palIndex: SomeInteger): ppal.Palette =
  newPalette(cram.palettes[palIndex], true)

proc `[]=`*(cram: ColorRAM; palIndex: SomeInteger; palette: ppal.Palette) =
  let cramData = cram.palettes[palIndex].getData(0)
  let pal = palette.getData()
  let palData = pal.getData(0)
  let maxLen = min(cram.length, pal.getNumColors())
  copyMem(cramData, palData, maxLen * sizeof(Color))

proc `[]=`*(cram: ColorRAM; palIndex: SomeInteger; data: Span[Color]) =
  let cramData = cram.palettes[palIndex].getData()
  let palData = data.dataPtr
  let maxLen = min(cram.length, data.len)
  copyMem(cramData, palData, maxLen * sizeof(Color))

proc `[]=`*(cram: ColorRAM; palIndex: SomeInteger; data: openArray[Color]) =
  let cramData = cram.palettes[palIndex].getData()
  let palData = data[0].addr
  let maxLen = min(cram.length, data.len)
  copyMem(cramData, palData, maxLen * sizeof(Color))

proc swap*(cram: ColorRAM, pal1: SomeInteger, pal2: SomeInteger) =
  var dat1 = cast[ptr UncheckedArray[uint32]](cram.palettes[pal1].getData(0))
  var dat2 = cast[ptr UncheckedArray[uint32]](cram.palettes[pal2].getData(0))
  var tmp: uint32 = 0
  for i in 0..<cram.length:
    tmp = dat1[i]
    dat1[i] = dat2[i]
    dat2[i] = tmp

proc getData*(cram: ColorRAM, palIndex: SomeInteger): Span[Color] =
  Span[Color].new(cast[ptr UncheckedArray[Color]](cram.palettes[palIndex].getData(0)), cram.length)

proc getTlnPalette*(cram: ColorRAM, palIndex: SomeInteger): tilengine.Palette =
  cram.palettes[palIndex]