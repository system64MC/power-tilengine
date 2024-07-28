import tilengine

type
  ObjectListImpl = object
    data: tilengine.ObjectList
    fromTilengine: bool

  ObjectList* = ref ObjectListImpl

proc `=destroy`(ol: ObjectListImpl) =
  if (not ol.fromTilengine) and (ol.data != nil): ol.data.delete()

proc setTilengine*(ol: ObjectList, value: bool = true) =
  ol.fromTilengine = true

proc getTilengine*(ol: ObjectList): bool =
  ol.fromTilengine


proc setData*(ol: ObjectList, data: tilengine.ObjectList) =
  ol.data = data

proc getData*(ol: ObjectList): tilengine.ObjectList = ol.data

proc newObjectList*(data: tilengine.ObjectList, fromTilengine: bool): ObjectList =
  ObjectList(data: data, fromTilengine: fromTilengine)