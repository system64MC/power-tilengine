import tilengine

type
  SpritesetImpl = object
    data: tilengine.Spriteset
    fromTilengine: bool

  Spriteset* = ref SpritesetImpl

proc `=destroy`(sset: SpritesetImpl) =
  if (not sset.fromTilengine) and (sset.data != nil): sset.data.delete()

proc setTilengine*(sset: Spriteset, value: bool = true) =
  sset.fromTilengine = true

proc getTilengine*(sset: Spriteset): bool =
  sset.fromTilengine


proc setData*(sset: Spriteset, data: tilengine.Spriteset) =
  sset.data = data

proc getData*(sset: Spriteset): tilengine.Spriteset = sset.data

proc newSpriteset*(data: tilengine.Spriteset, fromTilengine: bool): Spriteset =
  Spriteset(data: data, fromTilengine: fromTilengine)