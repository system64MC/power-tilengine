import tilengine

type
  TilemapImpl = object
    data: tilengine.Tilemap
    fromTilengine: bool

  Tilemap* = ref TilemapImpl

proc `=destroy`(tmap: TilemapImpl) =
  if (not tmap.fromTilengine) and (tmap.data != nil): tmap.data.delete()

proc setTilengine*(tmap: Tilemap, value: bool = true) =
  tmap.fromTilengine = true

proc getTilengine*(tmap: Tilemap): bool =
  tmap.fromTilengine


proc setData*(tmap: Tilemap, data: tilengine.Tilemap) =
  tmap.data = data

proc getData*(tmap: Tilemap): tilengine.Tilemap = tmap.data

proc newTilemap*(data: tilengine.Tilemap, fromTilengine: bool): Tilemap =
  Tilemap(data: data, fromTilengine: fromTilengine)