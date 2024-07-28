import tilengine

type
  TilesetImpl = object
    data: tilengine.Tileset
    fromTilengine: bool

  Tileset* = ref TilesetImpl

proc `=destroy`(tset: TilesetImpl) =
  if (not tset.fromTilengine) and (tset.data != nil): tset.data.delete()

proc setTilengine*(tset: Tileset, value: bool = true) =
  tset.fromTilengine = true

proc getTilengine*(tset: Tileset): bool =
  tset.fromTilengine


proc setData*(tset: Tileset, data: tilengine.Tileset) =
  tset.data = data

proc getData*(tset: Tileset): tilengine.Tileset = tset.data

proc newTileset*(data: tilengine.Tileset, fromTilengine: bool): Tileset =
  Tileset(data: data, fromTilengine: fromTilengine)