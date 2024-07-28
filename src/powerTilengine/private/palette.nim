import tilengine

type
  PaletteImpl = object
    data: tilengine.Palette
    fromTilengine: bool

  Palette* = ref PaletteImpl

proc `=destroy`(pal: PaletteImpl) =
  if (not pal.fromTilengine) and (pal.data != nil): pal.data.delete()

proc setTilengine*(pal: Palette, value: bool = true) =
  pal.fromTilengine = true

proc getTilengine*(pal: Palette): bool =
  pal.fromTilengine


proc setData*(pal: Palette, data: tilengine.Palette) =
  pal.data = data

proc getData*(pal: Palette): tilengine.Palette = pal.data

proc newPalette*(data: tilengine.Palette, fromTilengine: bool): Palette =
  Palette(data: data, fromTilengine: fromTilengine)