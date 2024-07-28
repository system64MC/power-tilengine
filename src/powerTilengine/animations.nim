import tilengine
import private/palette as ppal
import private/sequence as pseq

type
  Animation* = int

  AnimationState* = enum
    Play
    Pause
    Disable

proc setPalette*(animation: Animation, palette: ppal.Palette, sequence: pseq.Sequence, blend: bool) =
  setPaletteAnimation(animation, palette.getData(), sequence.getData(), blend)

proc `palette=`*(animation: Animation, palette: ppal.Palette) =
  setPaletteAnimationSource(animation, palette.getData())

proc `active`*(animation: Animation): bool =
  getAnimationState(animation)

proc `delay=`*(animation: Animation; data: (SomeInteger, SomeInteger)) =
  setAnimationDelay(animation, data[0].int, data[1].int)

proc getAvailable*(_: typedesc[Animation]): int = getAvailableAnimation()  

proc disable*(animation: Animation) = disablePaletteAnimation(animation)