import tilengine

type
  SequenceImpl = object
    data: tilengine.Sequence
    fromTilengine: bool

  Sequence* = ref SequenceImpl

proc `=destroy`(s: SequenceImpl) =
  if (not s.fromTilengine) and (s.data != nil): s.data.delete()

proc setTilengine*(s: Sequence, value: bool = true) =
  s.fromTilengine = true

proc getTilengine*(s: Sequence): bool =
  s.fromTilengine


proc setData*(s: Sequence, data: tilengine.Sequence) =
  s.data = data

proc getData*(s: Sequence): tilengine.Sequence = s.data

proc newSequence*(data: tilengine.Sequence, fromTilengine: bool): Sequence =
  Sequence(data: data, fromTilengine: fromTilengine)