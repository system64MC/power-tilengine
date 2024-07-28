import tilengine

type
  BitmapImpl = object
    data: tilengine.Bitmap
    fromTilengine: bool

  Bitmap* = ref BitmapImpl

proc `=destroy`(bmap: BitmapImpl) =
  if (not bmap.fromTilengine) and (bmap.data != nil): bmap.data.delete()

proc setTilengine*(bmap: Bitmap, value: bool = true) =
  bmap.fromTilengine = true

proc getTilengine*(bmap: Bitmap): bool =
  bmap.fromTilengine


proc setData*(bmap: Bitmap, data: tilengine.Bitmap) =
  bmap.data = data

proc getData*(bmap: Bitmap): tilengine.Bitmap = bmap.data

proc newBitmap*(data: tilengine.Bitmap, fromTilengine: bool): Bitmap =
  Bitmap(data: data, fromTilengine: fromTilengine)