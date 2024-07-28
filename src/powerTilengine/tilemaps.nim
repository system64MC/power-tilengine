import tilengine
import colors
import rectangle
import spans
import private/tilemap as ptmap
import private/tileset as ptset
import exceptions

## Creates a new tilemap
proc new*(_: typedesc[ptmap.Tilemap], width, height: SomeInteger, tiles: openArray[Tile] = [], bgColor: Color = Color(), tileset: ptset.Tileset = nil): ptmap.Tilemap =
  newTilemap(
    result = createTilemap(
      height, width, 
      if(tiles == nil or (tiles.len == 0)): nil 
      else: cast[ptr UncheckedArray[Tile]](tiles[0].addr), 
      cast[uint32](bgColor), 
      if(tileset == nil): nil else: tileset.getData()
    ), 
    false)
  tileset.setTilengine(true)

proc load*(_: typedesc[ptmap.Tilemap], filename: string): ptmap.Tilemap =
  newTilemap(
    loadTilemap(filename.cstring, nil),
    false
  )
proc load*(_: typedesc[ptmap.Tilemap], filename: string, layername: string): ptmap.Tilemap =
  newTilemap(
    loadTilemap(filename.cstring, layername.cstring),
    false
  )

proc `some`*(tmap: ptmap.Tilemap): bool =
  tmap.getData() != nil

proc `none`*(tmap: ptmap.Tilemap): bool =
  tmap.getData() == nil

proc clone*(tilemap: ptmap.Tilemap): ptmap.Tilemap = newTilemap(tilengine.clone(tilemap.getData()), false)
proc `rows`*(tilemap: ptmap.Tilemap): int = getRows(tilemap.getData())
proc `cols`*(tilemap: ptmap.Tilemap): int = getCols(tilemap.getData())

type TilemapTilesets* = object
  tmap: tilengine.Tilemap

proc `tilesets`*(tilemap: ptmap.Tilemap): TilemapTilesets = TilemapTilesets(tmap: tilemap.getData())
proc `[]`*(tsets: TilemapTilesets; idx: range[0..7]): ptset.Tileset = newTileset(getTileset(tsets.tmap, idx), true)
proc `[]=`*(tsets: TilemapTilesets; idx: range[0..7], value: ptset.Tileset) = 
  if(value.getTilengine()): raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let t = tsets.tmap.getTileset(idx)
  setTileset(tsets.tmap, value.getData(), idx)
  value.setTilengine(true)
  if(t != nil): t.delete()

proc `tileset`*(tilemap: ptmap.Tilemap): ptset.Tileset = 
  newTileset(getTileset(tilemap.getData()), true)

proc `tileset=`*(tilemap: ptmap.Tilemap, value: ptset.Tileset) = 
  if(value.getTilengine()): raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let t = tilemap.getData().getTileset()
  setTileset(tilemap.getData(), value.getData())
  value.setTilengine(true)
  if(t != nil): t.delete()

proc `tilesetCopy=`*(tilemap: ptmap.Tilemap, value: ptset.Tileset) = 
  setTileset(tilemap.getData(), value.getData().clone())

proc `[]=`*(tilemap: ptmap.Tilemap; x: SomeInteger, y: SomeInteger, tile: Tile) {.inline.} =
  # if(x < 0 or x > tilemap.getCols or y < 0 or y > tilemap.getRows): return
  tilemap.getData().setTile(y.int, x.int, tile)

proc `[]`*(tilemap: ptmap.Tilemap; x: SomeInteger, y: SomeInteger): Tile {.inline.} =
  # if(x < 0 or x > tilemap.getCols or y < 0 or y > tilemap.getRows): raise e
  return tilemap.getData().getTile(y.int, x.int)

proc copyTiles*[T: SomeNumber](src: ptmap.Tilemap, srcRect: Rectangle[T], dest: ptmap.Tilemap, destRect: Rectangle[T]) =
  copyTiles(
    src.getData(), 
    srcRect.y.int, srcRect.x.int, src.height.int, src.width.int, 
    dest.getData(), 
    destRect.y.int, destRect.x.int, destRect.height.int, destRect.width.int
  )

proc getTiles*(tilemap: ptmap.Tilemap, x: SomeInteger, y: SomeInteger): Span[Tile] = 
  Span.new(
    tilengine.getTiles(tilemap.getData(), y.int, x.int), 
    (tilemap.getRows() * tilemap.getCols()) - (y.int * tilemap.getCols() + x.int)
  )

proc delete*(tilemap: ptmap.Tilemap) =
  tilemap.getData().delete()
  tilemap.setData(nil)

export ptmap.Tilemap
export ptset.Tileset

export tilengine.Tile
export tilengine.TileFlags

export tilengine.`palette`
export tilengine.`tileset`
export tilengine.`masked`
export tilengine.`priority`
export tilengine.`rotate`
export tilengine.`flipy`
export tilengine.`flipx`

export tilengine.`palette=`
export tilengine.`tileset=`
export tilengine.`masked=`
export tilengine.`priority=`
export tilengine.`rotate=`
export tilengine.`flipy=`
export tilengine.`flipx=`

export tilengine.`tileFlags`