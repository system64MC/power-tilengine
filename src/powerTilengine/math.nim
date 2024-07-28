import std/math as m

func lerp*(y0, y1: SomeNumber, t: float): float =
  y0.float + (y1.float - y0.float) * t

proc lerp*(a, b, t: uint8): uint8 =
  return ((a.uint16 * (256 - t.uint16) + b.uint16 * t.uint16) shr 8).uint8

func min*(vals: openArray[SomeNumber]): SomeNumber =
  result = vals[0]
  for i in vals:
    if i < result: result = i

func max*(vals: openArray[SomeNumber]): SomeNumber =
  result = vals[0]
  for i in vals:
    if i > result: result = i

export m