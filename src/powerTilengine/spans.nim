type
  Span*[T] = object
    data: ptr UncheckedArray[T]
    length: int

func new*[T](_: typedesc[Span], data: ptr UncheckedArray[T], length: int): Span[T] =
  return Span[T](data: data, length: length)

func `len`*[T](span: Span[T]): int =
  return span.length

func `dataPtr`*[T](span: Span[T]): ptr UncheckedArray[T] =
  return span.data

func `[]`*[T](span: Span[T]; idx: SomeInteger): T =
  return span.data.toOpenArray(0, span.length)[idx]

proc `[]=`*[T](span: Span[T]; idx: SomeInteger, value: T) =
  span.data.toOpenArray(0, span.length)[idx] = T

iterator items*[T](span: Span[T]): T =
  for i in 0..<span.lenth:
    yield span.data[i]

iterator mitems*[T](span: Span[T]): var T =
  for i in 0..<span.length:
    yield span.data[i]