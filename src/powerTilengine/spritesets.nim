import tilengine
import private/spriteset as psset
import private/bitmap as pbmap
import private/palette as ppal
import exceptions

proc new*(_: typedesc[psset.Spriteset], bitmap: pbmap.Bitmap, data: openArray[SpriteData]): psset.Spriteset =
  if(bitmap.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  newSpriteset(createSpriteset(bitmap.getData(), cast[ptr UncheckedArray[SpriteData]](data[0].addr), data.len.int), false)

proc load*(_: typedesc[psset.Spriteset], filename: string): psset.Spriteset =
  newSpriteset(loadSpriteset(filename.cstring), false)

proc clone*(spriteset: psset.Spriteset): psset.Spriteset =
  newSpriteset(clone(spriteset.getData()), false)

proc `[]`*(spriteset: psset.Spriteset; entry: SomeInteger): SpriteInfo =
  getSpriteInfo(spriteset.getData(), entry.int)

proc `[]`*(spriteset: psset.Spriteset; name: string): int =
  findSprite(spriteset.getData(), name.cstring)

proc `palette`*(spriteset: psset.Spriteset): ppal.Palette =
  newPalette(getPalette(spriteset.getData()), true)

proc setData*(spriteset: psset.Spriteset, entry: SomeInteger, data: SpriteData, pixels: openArray[uint8], pitch: SomeInteger) =
  setData(spriteset.getData(), entry.int, data, pixels[0].addr, pitch.int)

proc delete*(spriteset: psset.Spriteset) =
  spriteset.getData().delete()
  spriteset.setData(nil)

export psset.Spriteset
export tilengine.SpriteData
export tilengine.SpriteInfo