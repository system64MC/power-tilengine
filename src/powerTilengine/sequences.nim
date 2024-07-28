import tilengine
import private/sequence as pseq
import private/spriteset as psset

proc new*(_: typedesc[pseq.Sequence], name: string, target: SomeInteger, frames: openArray[SequenceFrame]): pseq.Sequence =
  newSequence(createSequence(name.cstring, target.int, frames.len.int, cast[ptr UncheckedArray[SequenceFrame]](frames[0].addr)), false)

proc new*(_: typedesc[pseq.Sequence], name: string, strips: openArray[ColorStrip]): pseq.Sequence =
  newSequence(createCycle(name.cstring, strips.len.int, cast[ptr UncheckedArray[ColorStrip]](strips[0].addr)), false)

proc new*(_: typedesc[pseq.Sequence], name: string, spriteset: psset.Spriteset, baseName: string, delay: SomeInteger): pseq.Sequence =
  newSequence(createSpriteSequence(name.cstring, spriteset.getData(), baseName.cstring, delay.int32), false)
  spriteset.setTilengine(true)

proc clone*(sequence: pseq.Sequence): pseq.Sequence =
  newSequence(sequence.getData().clone(), false)

proc `info`*(sequence: pseq.Sequence): SequenceInfo =
  getInfo(sequence.getData())

proc delete*(sequence: pseq.Sequence) =
  sequence.getData().delete()

export pseq.Sequence
export tilengine.SequenceFrame
export tilengine.ColorStrip
export tilengine.SequenceInfo