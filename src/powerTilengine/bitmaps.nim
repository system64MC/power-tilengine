import tilengine
import private/bitmap as pbmap
import private/palette as ppal
import private/cram as pcram
import private/context as pctx
import spans
import exceptions

proc new*(_: typedesc[pbmap.Bitmap], width, height, bpp: int): pbmap.Bitmap =
  newBitmap(createBitmap(width, height, bpp), false)

proc load*(_: typedesc[pbmap.Bitmap], filename: string, sanitize: bool = false): pbmap.Bitmap =
  newBitmap(loadBitmap(filename.cstring), false)

proc clone*(bitmap: pbmap.Bitmap): pbmap.Bitmap =
  newBitmap(bitmap.getData().clone(), false)

proc getData*(bitmap: pbmap.Bitmap, x: SomeInteger, y: SomeInteger): Span[uint8] = 
  Span.new(
    tilengine.getData(bitmap.getData(), x.int, y.int), 
    (bitmap.getWidth() * bitmap.getHeight()) - (y.int * bitmap.getWidth() + x.int)
  )

proc `[]=`*(bitmap: pbmap.Bitmap; x: SomeInteger, y: SomeInteger, color: byte) {.inline.} =
  # if(x < 0 or x > bitmap.getWidth or y < 0 or y > bitmap.getHeight): return
  getData(bitmap.getData(), x.int, y.int)[0] = color

proc `[]`*(bitmap: pbmap.Bitmap; x: SomeInteger, y: SomeInteger): byte {.inline.} =
  # if(x < 0 or x > bitmap.getWidth or y < 0 or y > bitmap.getHeight): raise e
  getData(bitmap.getData(), x.int, y.int)[0]

proc `data`*(bitmap: pbmap.Bitmap): Span[uint8] =
  Span.new(bitmap.getData().getData(0, 0), bitmap.getData().getWidth() * bitmap.getData().getHeight())

proc `width`*(bitmap: pbmap.Bitmap): int =
  bitmap.getData().getWidth()

proc `height`*(bitmap: pbmap.Bitmap): int =
  bitmap.getData().getHeight()

proc `depth`*(bitmap: pbmap.Bitmap): int =
  bitmap.getData().getDepth()

proc `pitch`*(bitmap: pbmap.Bitmap): int =
  bitmap.getData().getPitch()

proc `palette`*(bitmap: pbmap.Bitmap): ppal.Palette =
  newPalette(bitmap.getData().getPalette(), true)

# proc `palette=`*(bitmap: pbmap.Bitmap, value: ppal.Palette) =
#   if(value.getTilengine()): raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
#   let p = bitmap.getData().getPalette()
#   setPalette(bitmap.getData(), value.getData())
#   value.setTilengine(true)
#   if(p != nil): p.delete()

proc `palette=`*(bitmap: pbmap.Bitmap, value: SomeInteger) =
  if(not bitmap.getTilengine()): 
    raise newException(OwnershipError, "Cannot set global palette because this object doesn't belong to Tilengine yet.")
  bitmap.getData().setPalette(ctx.getCram().getTlnPalette(value))

proc delete*(bitmap: pbmap.Bitmap) =
  if(bitmap.getData() != nil): bitmap.getData().delete()
  bitmap.setData(nil)

export pbmap.Bitmap