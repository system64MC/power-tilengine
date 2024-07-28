import tilengine
import private/palette as ppal
import colors
import spans
import exceptions

proc new*(_: typedesc[ppal.Palette], entries: SomeInteger): ppal.Palette =
  newPalette(createPalette(entries.int), false)

proc load*(_: typedesc[ppal.Palette], filename: string): ppal.Palette =
  newPalette(loadPalette(filename.cstring), false)

proc clone*(pal: ppal.Palette): ppal.Palette =
  newPalette(pal.getData().clone(), false)

proc `[]`*(pal: ppal.Palette; index: SomeInteger): Color =
  let dat = pal.getData()
  let s = Span[Color].new(cast[ptr UncheckedArray[Color]](dat.getData(0)), dat.getNumColors())
  s[index]
  
proc `[]=`*(pal: ppal.Palette; index: SomeInteger, color: Color) =
  let dat = pal.getData()
  let s = Span[Color].new(dat.getData(0), dat.getNumColors())
  s[index] = color

proc addColor*(pal: ppal.Palette; color: Color; start, num: SomeInteger) = addColor(pal.getData(), color.r, color.g, color.b, start.uint8, num.uint8)
proc subColor*(pal: ppal.Palette; color: Color; start, num: SomeInteger) = subColor(pal.getData(), color.r, color.g, color.b, start.uint8, num.uint8)
proc modColor*(pal: ppal.Palette; color: Color; start, num: SomeInteger) = modColor(pal.getData(), color.r, color.g, color.b, start.uint8, num.uint8)

proc `+=`*(pal: ppal.Palette; color: Color) = addColor(pal.getData(), color.r, color.g, color.b, 0, pal.getData().getNumColors().uint8)
proc `-=`*(pal: ppal.Palette; color: Color) = subColor(pal.getData(), color.r, color.g, color.b, 0, pal.getData().getNumColors().uint8)
proc `*=`*(pal: ppal.Palette; color: Color) = modColor(pal.getData(), color.r, color.g, color.b, 0, pal.getData().getNumColors().uint8)

proc `+`*(pal: ppal.Palette; color: Color): ppal.Palette =
  let orig = pal.getData()
  let newPal = orig.clone()
  addColor(newPal, color.r, color.g, color.b, 0, newPal.getNumColors().uint8)
  newPalette(newPal, false)

proc `-`*(pal: ppal.Palette; color: Color): ppal.Palette =
  let orig = pal.getData()
  let newPal = orig.clone()
  subColor(newPal, color.r, color.g, color.b, 0, newPal.getNumColors().uint8)
  newPalette(newPal, false)

proc `*`*(pal: ppal.Palette; color: Color): ppal.Palette =
  let orig = pal.getData()
  let newPal = orig.clone()
  modColor(newPal, color.r, color.g, color.b, 0, newPal.getNumColors().uint8)
  newPalette(newPal, false)

proc `len`*(pal: ppal.Palette): int =
  pal.getData().getNumColors()

proc setLen*(pal: ppal.Palette, len: SomeInteger) =
  if(pal.getTilengine()): raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let palPtr = pal.getData()
  let palLen = palPtr.getNumColors()
  let palData = palPtr.getData(0)
  let pal2 = createPalette(len)
  let pal2Data = pal2.getData(0)
  copyMem(pal2Data, palData, min(len, palLen) * sizeof(Color))
  palPtr.delete()
  pal.setData(pal2)

proc `data`*(pal: ppal.Palette): Span[Color] =
  let dat = pal.getData()
  Span[Color].new(cast[ptr UncheckedArray[Color]](dat.getData(0)), dat.getNumColors())

proc `data=`*(pal: ppal.Palette; data: openArray[Color]) =
  let palPtr = pal.getData()
  let palLen = palPtr.getNumColors()
  let palData = palPtr.getData(0)
  copyMem(palData, data[0].addr, min(data.len, palLen) * sizeof(Color))

proc `data=`*(pal: ppal.Palette; pal2: ppal.Palette) =
  let palPtr = pal.getData()
  let palLen = palPtr.getNumColors()
  let palData = palPtr.getData(0)
  let pal2Ptr = pal2.getData()
  let pal2Data = pal2Ptr.getData(0)
  let pal2Len = pal2Ptr.getNumColors()
  copyMem(palData, pal2Data, min(palLen, pal2Len) * sizeof(Color))

proc convert*(pal: ppal.Palette, convert: ColorConverter) =
  var dat = pal.data
  for color in dat.mitems:
      color.convert(convert)

proc invert*(pal: ppal.Palette) =
  var dat = pal.data
  for color in dat.mitems:
      color.invert()

proc delete*(pal: ppal.Palette) =
  pal.getData().delete()
  pal.setData(nil)

export ppal.Palette