import tilengine

type
  SequencePackImpl = object
    data: tilengine.SequencePack
    fromTilengine: bool

  SequencePack* = ref SequencePackImpl

proc `=destroy`(sp: SequencePackImpl) =
  if (not sp.fromTilengine) and (sp.data != nil): sp.data.delete()

proc setTilengine*(sp: SequencePack, value: bool = true) =
  sp.fromTilengine = true

proc getTilengine*(sp: SequencePack): bool =
  sp.fromTilengine


proc setData*(sp: SequencePack, data: tilengine.SequencePack) =
  sp.data = data

proc getData*(sp: SequencePack): tilengine.SequencePack = sp.data

proc newSequencePack*(data: tilengine.SequencePack, fromTilengine: bool): SequencePack =
  SequencePack(data: data, fromTilengine: fromTilengine)