import tilengine
import private/sequencepack as psp
import private/sequence as pseq

proc new*(_: typedesc[psp.SequencePack]): psp.SequencePack =
  newSequencePack(createSequencePack(), false)

proc load*(_: typedesc[psp.SequencePack], filename: string): psp.SequencePack =
  newSequencePack(loadSequencePack(filename.cstring), false)

proc `[]`*(sp: psp.SequencePack; index: SomeInteger): pseq.Sequence =
  newSequence(getSequence(sp.getData(), index.int), true)

proc `[]`*(sp: psp.SequencePack; name: string): pseq.Sequence =
  newSequence(findSequence(sp.getData(), name.cstring), true)

proc `count`*(sp: psp.SequencePack): int =
  getCount(sp.getData())

proc add*(sp: psp.SequencePack, sequence: pseq.Sequence) =
  addSequence(sp.getData(), sequence.getData())

proc delete*(sp: psp.SequencePack) =
  sp.getData().delete()
  sp.setData(nil)

export psp.SequencePack