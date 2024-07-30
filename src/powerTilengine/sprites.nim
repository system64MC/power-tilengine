import tilengine
import private/spriteset as psset
import private/palette as ppal
import private/sequence as pseq
import private/cram as pcram
import private/context as pctx
import vectors
import exceptions
from animations import AnimationState

proc config*(sprite: Sprite, spriteset: psset.Spriteset, flags: set[SpriteFlag]) = configSprite(sprite, spriteset.getData(), flags)

proc `spriteset=`*(sprite: Sprite, spriteset: psset.Spriteset) =
  ctx.setSpriteSet(sprite.int32, spriteset)
  setSpriteset(sprite, spriteset.getData())

proc `spriteset`*(sprite: Sprite): psset.Spriteset =
  return ctx.getSpriteSet(sprite.int32)

proc `flags=`*(sprite: Sprite, flags: set[SpriteFlag]) = setFlags(sprite, flags)

proc `pivot=`*(sprite: Sprite, data: (SomeFloat, SomeFloat)) = setPivot(sprite, data[0].float32, data[1].float32)
proc `pivot=`*(sprite: Sprite, data: GVec2[SomeFloat]) = setPivot(sprite, data[0].float32, data[1].float32)

proc `position=`*(sprite: Sprite, data: (SomeNumber, SomeNumber)) = setPosition(sprite, data[0].int, data[1].int)
proc `position=`*(sprite: Sprite, data: GVec2[SomeNumber]) = setPosition(sprite, data[0].int, data[1].int)
proc `position`*(sprite: Sprite): GVec2[int] = gvec2[int](sprite.getX(), sprite.getY())

proc `picture=`*(sprite: Sprite, picture: SomeInteger) = setPicture(sprite, picture.int)
proc `picture`*(sprite: Sprite): int = getPicture(sprite)

proc `palette=`*(sprite: Sprite, palette: SomeInteger) =
  sprite.setPalette(ctx.getCram()[palette].getData())

proc `palette`*(sprite: Sprite): ppal.Palette =
  newPalette(sprite.getPalette(), true)

proc `blendMode=`*(sprite: Sprite, data: (Blend, uint8)) = setBlendMode(sprite, data[0], data[1])

proc `scaling=`*(sprite: Sprite, data: GVec2[SomeNumber]) = setScaling(sprite, data.x.float32, data.y.float32)
proc `scaling=`*(sprite: Sprite, data: SomeNumber) = setScaling(sprite, data.float32, data.float32)

proc `x`*(sprite: Sprite): int = sprite.getX()
proc `x=`*(sprite: Sprite; value: SomeNumber) = sprite.setPosition(value.int, sprite.getY())

proc `y`*(sprite: Sprite): int = sprite.getY()
proc `y=`*(sprite: Sprite; value: SomeNumber) = sprite.setPosition(sprite.getX(), value.int)

proc getAvailable*(_: typedesc[Sprite]): Sprite = Sprite(getAvailableSprite())

proc `enableCollisions=`*(sprite: Sprite, value: bool) = enableCollision(sprite, value)
proc `collision`*(sprite: Sprite): bool = getCollision(sprite)

proc `state`*(sprite: Sprite): SpriteState = getState(sprite)

proc `first=`*(_: typedesc[Sprite], value: Sprite) = setFirstSprite(value)
proc `next=`*(sprite: Sprite, value: Sprite) = setNextSprite(sprite, value)

proc `masking=`*(sprite: Sprite, value: bool) = enableMasking(sprite, value)

proc `maskRegion=`*(_: typedesc[Sprite], value: (SomeInteger, SomeInteger)) = setSpritesMaskRegion(value[0].int, value[1].int)

proc `animation=`*(sprite: Sprite, value: (pseq.Sequence, SomeInteger)) = setAnimation(sprite, value[0].getValue(), value[1].int)

proc `animationState=`*(sprite: Sprite, value: AnimationState) =
  case value:
  of Play: resumeAnimation(sprite)
  of Pause: pauseAnimation(sprite)
  of Disable: disableAnimation(sprite)


export tilengine.Sprite
export tilengine.SpriteFlag
export tilengine.SpriteState
export tilengine.enableFlags
export tilengine.disableFlags
export tilengine.resetScaling
