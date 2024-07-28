import tilengine
import private/tileset as ptset
import private/bitmap as pbmap
import private/palette as ppal
import private/sequencepack as psp

type
  TileImage* = object
    bitmap*: pbmap.Bitmap
    id*: uint16
    kind*: uint8

proc new*(_: typedesc[ptset.Tileset], numTiles: SomeInteger; width, height: SomeInteger; palette: ppal.Palette; sp: psp.SequencePack = nil; attributes: openArray[TileAttributes] = []): ptset.Tileset =
  newTileset(createTileset(numTiles, numTiles.int, width.int, height.int, palette.getData(), if(sp == nil): nil else: sp.getData(), if(attributes.len == 0): nil else: cast[ptr UncheckedArray[TileAttributes]](attributes[0].addr)), false)

proc new*(_: typedesc[ptset.Tileset], numTiles: SomeInteger, images: openArray[TileImage] = []): ptset.Tileset =
  if(images.len == 0): return newTileset(createImageTileset(numTiles.int, nil), false)
  
  for img in images:
    if(img.getTilengine()):
      raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  
  var imagesSeq = newSeq[tilengine.TileImage](images.len)
  for i in 0..<images.len:
    imagesSeq[i].bitmap = images[i].bitmap.getData()
    imagesSeq[i].id = images[i].id
    imagesSeq[i].kind = images[i].kind
    images[i].setTilengine(true)
  
  return newTileset(createImageTileset(numTiles, cast[ptr UncheckedArray[TileImage]](imagesSeq[0].addr)), false)

proc load*(_: typedesc[ptset.Tileset], filename: string): ptset.Tileset =
  newTileset(loadTileset(filename.cstring), false)

proc clone*(tileset: ptset.Tileset): ptset.Tileset =
  newTileset(tileset.getData().clone(), false)

proc setPixels*(tileset: ptset.Tileset, entry: SomeInteger, pixels: openArray[uint8], pitch: SomeInteger) =
  setPixels(tileset.getData(), entry.int, cast[ptr UncheckedArray[uint8]](pixels[0].addr), pitch.int)

proc `tileWidth`*(tileset: ptset.Tileset): int =
  tileset.getData().getTileWidth()

proc `tileHeight`*(tileset: ptset.Tileset): int =
  tileset.getData().getTileHeight()

proc `numTiles`*(tileset: ptset.Tileset): int =
  tileset.getData().getNumTiles()

proc `palette`*(tileset: ptset.Tileset): ppal.Palette =
  newPalette(tileset.getData().getPalette(), true)

proc `sequencePack`*(tileset: ptset.Tileset): psp.SequencePack =
  newSequencePack(tileset.getData().getSequencePack(), true)

proc delete*(tileset: ptset.Tileset) =
  tileset.getData().delete()
  tileset.setData(nil)

export ptset.Tileset