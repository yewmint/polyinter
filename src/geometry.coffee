class Point

  constructor: (@x, @y)->

  clone: ()->
    return new Point(@x, @y)

  offset: (point)->
    return new Point(@x + point.x, @y + point.y)


class Vertex

  constructor: (point, @segOut = null, @segIn = null)->
    @point = point.clone()

  destroy: ()->
    @point = null
    @segOut = null
    @segIn = null


class Segment

  constructor: (@vertexA, @vertexB)->

  destroy: ()->
    @vertexA = null
    @vertexB = null


class Polygon

  constructor: (points)->
    if points.length <= 2 then return null

    @vertexes = []

    for point in points
      @vertexes.push new Vertex(point)

    @vertexes.forEach (vertex, index, arr)=>
      nextVertex = arr[(index + 1) % arr.length]
      prevVertex = arr[(index - 1 + arr.length) % arr.length]
      vertex.segOut = new Segment(vertex, nextVertex)
      vertex.segIn = new Segment(prevVertex, vertex)

  clone: ()->
    points = []
    for vertex in @vertexes
      points.push vertex.point.clone()
    return new Polygon(points)

  offset: (point)->
    points = []
    for vertex in @vertexes
      points.push vertex.point.offset(point)
    return new Polygon(points)


class Vector

  constructor: (@x, @y, @z)->

  clone: ()->
    return new Vector(@x, @y, @y)


createVectorFrom2Points = (pointA, pointB)->
  x = pointB.x - pointA.x
  y = pointB.y - pointA.y
  z = 0
  return new Vector(x, y, z)

crossProduct = (vecA, vecB)->
  x = vecA.y * vecB.z - vecA.z * vecB.y
  y = vecA.z * vecB.x - vecA.x * vecB.z
  z = vecA.x * vecB.y - vecA.y * vecB.x
  return new Vector(x, y, z)

getIntersection = (segA, segB)->

  r_px = segA.vertexA.point.x
  r_py = segA.vertexA.point.y
  r_dx = segA.vertexB.point.x - segA.vertexA.point.x
  r_dy = segA.vertexB.point.y - segA.vertexA.point.y

  s_px = segB.vertexA.point.x
  s_py = segB.vertexA.point.y
  s_dx = segB.vertexB.point.x - segB.vertexA.point.x
  s_dy = segB.vertexB.point.y - segB.vertexA.point.y

  H = s_dx * r_dy - r_dx * s_dy

  if H is 0
    return null

  Hrt = s_dx * (s_py - r_py) - s_dy * (s_px - r_px)
  Hst = r_dx * (s_py - r_py) - r_dy * (s_px - r_px)

  rt = Hrt / H
  st = Hst / H

  if rt < 0 or rt > 1 then return null
  if st < 0 or st > 1 then return null

  x = r_px + r_dx * rt
  y = r_py + r_dy * rt

  return new Point(x, y)

distanceOf = (pointA, pointB)->
  dx = pointB.x - pointA.x
  dy = pointB.y - pointA.y
  distance = Math.sqrt(dx * dx + dy * dy)
  return distance

isPointInsidePoly = (point, poly)->
  for vtx in poly.vertexes
    seg = vtx.segOut
    pointToHead = createVectorFrom2Points(point, seg.vertexA.point)
    pointToTail = createVectorFrom2Points(point, seg.vertexB.point)
    product = crossProduct(pointToHead, pointToTail)
    if product.z < 0
      return false
  return true

getRdians = (pointA, pointB)->
  dx = pointB.x - pointA.x
  dy = pointB.y - pointA.y
  Math.atan2(dy, dx)

module.exports = {
  Point: Point
  Vertex: Vertex
  Segment: Segment
  Polygon: Polygon
  Vector: Vector
  crossProduct: crossProduct
  createVectorFrom2Points: createVectorFrom2Points
  getIntersection: getIntersection
  distanceOf: distanceOf
  isPointInsidePoly: isPointInsidePoly
  getRdians: getRdians
}