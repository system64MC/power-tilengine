import tilengine
import private/tilemap as ptmap
import private/tileset as ptset
import private/bitmap as pbmap
import private/palette as ppal
import private/objectList as polist
import private/context as pctx
import private/cram as pcram
import vectors
import rectangle
import colors
import exceptions

# proc setup*(layer: Layer, tileset: ptset.Tileset, tilemap: ptmap.Tilemap) = 
#   setLayer(
#     layer, if(tileset == nil): nil else: tileset.getData(), 
#     if(tilemap == nil): nil else: tilemap.getData()
#   )
# 
#   if(tileset != nil): tileset.setTilengine(true)
#   if(tilemap != nil): tilemap.setTilengine(true)

# proc setupCopy*(layer: Layer, tileset: ptset.Tileset, tilemap: ptmap.Tilemap) = 
#   setLayer(layer, tileset.getData().clone(), tilemap.getData().clone())

type
  LayerItem* = object
    case kind: LayerType
    of LayerTile: tilemap: ptmap.Tilemap
    of LayerBitmap: bitmap: pbmap.Bitmap
    of LayerObject: objects: polist.ObjectList
    else: discard

proc `kind`*(layerItem: LayerItem): LayerType = layerItem.kind
proc `tilemap`*(layerItem: LayerItem): ptmap.Tilemap = layerItem.tilemap
proc `bitmap`*(layerItem: LayerItem): pbmap.Bitmap = layerItem.bitmap
proc `objects`*(layerItem: LayerItem): polist.ObjectList = layerItem.objects

proc layerItem*(tilemap: ptmap.Tilemap): LayerItem =
  LayerItem(kind: LayerTile, tilemap: tilemap)

proc layerItem*(bitmap: pbmap.Bitmap): LayerItem =
  LayerItem(kind: LayerBitmap, bitmap: bitmap)

proc layerItem*(objectList: polist.ObjectList): LayerItem =
  LayerItem(kind: LayerObject, objects: objectList)

proc layerItem*(): LayerItem =
  LayerItem(kind: LayerNone)

proc `tilemap`*(layer: Layer): ptmap.Tilemap = newTilemap(getTilemap(layer), true)
proc `tilemap=`*(layer: Layer, value: ptmap.Tilemap) =
  if(value.getTilengine()): raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  var
    t: tilengine.Tilemap
    b: tilengine.Bitmap
    o: tilengine.ObjectList
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    t = layer.getTilemap() 
  of LayerBitmap:
    b = layer.getBitmap()
  of LayerObject: 
    o = layer.getObjects()
  of LayerNone: discard
  setTilemap(layer, value.getData())
  value.setTilengine(true)
  case ltype:
  of LayerTile:
    if(t != nil): t.delete()
  of LayerBitmap:
    if(b != nil): 
      b.setPalette(createPalette(1))
      b.delete()
  of LayerObject: 
    if(o != nil): o.delete()
  of LayerNone: discard

proc `bitmap`*(layer: Layer): pbmap.Bitmap = newBitmap(getBitmap(layer), true)
proc `bitmap=`*(layer: Layer, value: pbmap.Bitmap) =
  if(value.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  var
    t: tilengine.Tilemap
    b: tilengine.Bitmap
    o: tilengine.ObjectList
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    t = layer.getTilemap() 
  of LayerBitmap:
    b = layer.getBitmap()
  of LayerObject: 
    o = layer.getObjects()
  of LayerNone: discard
  let bm = value.getData()
  setBitmap(layer, bm)
  bm.getPalette().delete()
  bm.setPalette(ctx.getCram().getTlnPalette(0))
  value.setTilengine(true)
  case ltype:
  of LayerTile:
    if(t != nil): t.delete()
  of LayerBitmap:
    if(b != nil): 
      b.setPalette(createPalette(1))
      b.delete()
  of LayerObject: 
    if(o != nil): o.delete()
  of LayerNone: discard

proc `objects=`*(layer: Layer, value: (polist.ObjectList, ptset.Tileset)) = 
  if(value[0].getTilengine() or (value[1] != nil and value[1].getTilengine())): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  var
    t: tilengine.Tilemap
    b: tilengine.Bitmap
    o: tilengine.ObjectList
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    t = layer.getTilemap() 
  of LayerBitmap:
    b = layer.getBitmap()
  of LayerObject: 
    o = layer.getObjects()
  of LayerNone: discard
  setObjects(layer, value[0].getData(), if(value[1] == nil): nil else: value[1].getData())
  value[0].setTilengine(true)
  if(value[1] != nil): value[1].setTilengine(true)
  case ltype:
  of LayerTile:
    if(t != nil): t.delete()
  of LayerBitmap:
    if(b != nil): 
      b.setPalette(createPalette(1))
      b.delete()
  of LayerObject: 
    if(o != nil): o.delete()
  of LayerNone: discard

# proc `objects=`*(layer: Layer, value: tuple[objects: polist.ObjectList, tileset: ptset.Tileset]) = 
#   if(value[0].getTilengine() or (value[1] != nil and value[1].getTilengine())): 
#     raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
#   let o = layer.getObjects()
#   setObjects(layer, value[0].getData(), if(value[1] == nil): nil else: value[1].getData())
#   value[0].setTilengine(true)
#   if(value[1] != nil): value[1].setTilengine(true)
#   if(o != nil): o.delete()

proc `item`*(value: Layer): LayerItem = 
  case value.getType():
  of LayerTile: result = layerItem(newTilemap(value.getTilemap(), true))
  of LayerBitmap: result = layerItem(newBitmap(value.getBitmap(), true))
  of LayerObject: result = layerItem(newObjectList(value.getObjects(), true))
  of LayerNone: result = layerItem()

proc `item=`*(layer: Layer, value: LayerItem) = 
  case value.kind:
  of LayerTile: layer.tilemap = value.tilemap
  of LayerBitmap: layer.bitmap = value.bitmap
  of LayerObject: layer.objects = (value.objects, nil)
  of LayerNone: discard
    
proc setTilemap*(layer: Layer, value: ptmap.Tilemap): LayerItem =
  if(value.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    result = layerItem(newTilemap(layer.getTilemap(), false)) 
  of LayerBitmap:
    let bmap = layer.getBitmap()
    bmap.setPalette(createPalette(1))
    result = layerItem(newBitmap(bmap, false))
  of LayerObject: 
    result = layerItem(newObjectList(layer.getObjects(), false))
  of LayerNone: 
    result = layerItem()
  setTilemap(layer, value.getData())
  value.setTilengine(true)

proc setBitmap*(layer: Layer, value: pbmap.Bitmap): LayerItem =
  if(value.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    result = layerItem(newTilemap(layer.getTilemap(), false)) 
  of LayerBitmap:
    let bmap = layer.getBitmap()
    bmap.setPalette(createPalette(1))
    result = layerItem(newBitmap(bmap, false))
  of LayerObject: 
    result = layerItem(newObjectList(layer.getObjects(), false))
  of LayerNone: 
    result = layerItem()
  let bitmap = value.getData()
  bitmap.getPalette().delete()
  bitmap.setPalette(ctx.getCram().getTlnPalette(0))
  setBitmap(layer, value.getData())
  value.setTilengine(true)

proc setObjects*(layer: Layer, value: polist.ObjectList, tileset: ptset.Tileset = nil): LayerItem =
  if(value.getTilengine() or (tileset != nil and tileset.getTilengine())): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let ltype = layer.getType()
  case ltype:
  of LayerTile:
    result = layerItem(newTilemap(layer.getTilemap(), false)) 
  of LayerBitmap:
    let bmap = layer.getBitmap()
    bmap.setPalette(createPalette(1))
    result = layerItem(newBitmap(bmap, false))
  of LayerObject: 
    result = layerItem(newObjectList(layer.getObjects(), false))
  of LayerNone: 
    result = layerItem()
  setObjects(layer, value.getData(), if(tileset == nil): nil else: tileset.getData())
  value.setTilengine(true) 

proc setItem*(layer: Layer, value: LayerItem): LayerItem =
  case value.kind:
  of LayerTile:
    result = layer.setTilemap(value.tilemap)
  of LayerBitmap:
    result = layer.setBitmap(value.bitmap)
  of LayerObject:
    result = layer.setObjects(value.objects)
  of LayerNone: discard

# proc `palette`*(layer: Layer): ppal.Palette = newPalette(getPalette(layer), true)
# proc `palette=`*(layer: Layer, value: ppal.Palette) = 
#   if(value.getTilengine()): 
#     raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
#   let p = layer.getPalette()
#   setPalette(layer, value.getData())
#   value.setTilengine(true)
#   if(p != nil): p.delete()

# proc `palette=`*(layer: Layer, index: SomeInteger) =
#   layer.setPalette(ctx.getCRAM().getTlnPalette(index))
#   setGlobalPalette(0, ctx.getCRAM().getTlnPalette(0))

proc `tileset`*(layer: Layer): ptset.Tileset = newTileset(getTileset(layer), true)
proc `tileset=`*(layer: Layer, value: ptset.Tileset) = 
  if(value.getTilengine()): 
    raise newException(OwnershipError, "This object already belongs to Tilengine,\nuse the 'clone()' procedure to fix this error.")
  let t = layer.getTileset()
  setLayer(layer, value.getData(), getTilemap(layer))
  value.setTilengine(true)
  if(t != nil): t.delete()

proc `position`*(layer: Layer): GVec2[int] = gvec2[int](getX(layer), getY(layer))
proc `position=`*(layer: Layer; value: GVec2[SomeNumber]) = setPosition(layer, value[0].int, value[1].int)

proc `scaling=`*(layer: Layer, value: GVec2[SomeFloat]) = setScaling(layer, value.x.float, value.y.float)
proc `scaling=`*(layer: Layer, value: SomeFloat) = setScaling(layer, value.float, value.float)

proc `affineTransform=`*(layer: Layer, value: Affine) = setAffineTransform(layer, value.addr)
proc disableAffineTransform*(layer: Layer) = tilengine.disableAffineTransform(layer)
proc setTransform*(layer: Layer; angle: SomeFloat; dx, dy, sx, sy: SomeFloat) = tilengine.setTransform(layer, angle.float32, dx.float32, dy.float32, sx.float32, sy.float32)

proc `pixelMap=`*(layer: Layer, table: openArray[PixelMap]) = 
  if(table.len == 0): disablePixelMapping(layer)
  else: setPixelMapping(layer, cast[ptr UncheckedArray[PixelMap]](table[0].addr))

proc `blend=`*(layer: Layer, value: (Blend, uint8)) = setBlendMode(layer, value[0], value[1])
proc `blend=`*(layer: Layer, value: tuple[mode: Blend, factor: uint8]) = setBlendMode(layer, value.mode, value.factor)

proc `columnOffsets=`*(layer: Layer, offsets: openArray[int32]) = 
  setColumnOffset(layer, if(offsets.len == 0): nil else: cast[ptr UncheckedArray[int32]](offsets[0].addr))

proc `window=`*(layer: Layer, value: (Rectangle[SomeNumber], bool)) = setWindow(layer, value[0].x.int, value[0].y.int, (value[0].x + value[0].width).int, (value[0].y + value[0].height).int, value[1])
proc `window=`*(layer: Layer, value: tuple[area: Rectangle[SomeNumber], invert: bool = false]) = setWindow(layer, value[0].x.int, value[0].y.int, (value[0].x + value[0].width).int, (value[0].y + value[0].height).int, value[1])

proc disableWindow*(layer: Layer) = tilengine.disableWindow(layer)

proc `windowColor=`*(layer: Layer, value: (Color, Blend)) = setWindowColor(layer, value[0].r, value[0].g, value[0].b, value[1])
proc `windowColor=`*(layer: Layer, value: tuple[color: Color, blend: Blend]) = setWindowColor(layer, value[0].r, value[0].g, value[0].b, value[1])
proc disableWindowColor*(layer: Layer) = tilengine.disableWindowColor(layer)

proc `mosaic=`*(layer: Layer, value: GVec2[SomeNumber]) = setMosaic(layer, value.x.int, value.y.int)
proc `mosaic=`*(layer: Layer, value: SomeNumber) = setMosaic(layer, value.int, value.int)
proc disableMosaic*(layer: Layer) = tilengine.disableMosaic(layer)

proc resetMode*(layer: Layer) = resetLayerMode(layer)

proc `objects`*(layer: Layer): polist.ObjectList = 
  newObjectList(getObjects(layer), true)

proc `priority=`*(layer: Layer, value: bool) = setPriority(layer, value)

proc `enable=`*(layer: Layer, value: bool) = 
  if(value): tilengine.enable(layer) else: tilengine.disable(layer)

proc `type`*(layer: Layer): LayerType = getType(layer)

proc `width`*(layer: Layer): int = getWidth(layer)
proc `height`*(layer: Layer): int = getHeight(layer)

proc `posX`*(layer: Layer): int = getX(layer)
proc `posX=`*(layer: Layer, value: SomeNumber) = setPosition(layer, value.int, getY(layer))
proc `posY`*(layer: Layer): int = getY(layer)
proc `posY=`*(layer: Layer, value: SomeNumber) = setPosition(layer, getX(layer), value.int)

proc `parallaxFactor=`*(layer: Layer, value: GVec2[SomeNumber]) = setParallaxFactor(layer, value.x.float32, value.y.float32)
proc `parallaxFactor=`*(layer: Layer, value: SomeNumber) = setParallaxFactor(layer, value.float32, value.float32)

proc swap*(layer1: Layer, layer2: Layer) =

  # Getting layer types
  let
    type1 = layer1.getType()
    type2 = layer2.getType()
  if(type1 == LayerNone or type2 == LayerNone): return

  var
    t1: tilengine.Tilemap
    b1: tilengine.Bitmap
    o1: tilengine.ObjectList

    t2: tilengine.Tilemap
    b2: tilengine.Bitmap
    o2: tilengine.ObjectList

  # getting data
  case type1:
  of LayerTile: t1 = layer1.getTilemap()
  of LayerBitmap: b1 = layer1.getBitmap()
  of LayerObject: o1 = layer1.getObjects()
  of LayerNone: return

  case type2:
  of LayerTile: t2 = layer2.getTilemap()
  of LayerBitmap: b2 = layer2.getBitmap()
  of LayerObject: o2 = layer2.getObjects()
  of LayerNone: return

  # Swapping
  case type1:
  of LayerTile: layer2.setTilemap(t1)
  of LayerBitmap: layer2.setBitmap(b1)
  of LayerObject: layer2.setObjects(o1, nil)
  of LayerNone: discard

  case type2:
  of LayerTile: layer1.setTilemap(t2)
  of LayerBitmap: layer1.setBitmap(b2)
  of LayerObject: layer1.setObjects(o2, nil)
  of LayerNone: discard
    

export tilengine.Layer
export tilengine.Affine
export tilengine.PixelMap
export tilengine.Blend
export tilengine.LayerType