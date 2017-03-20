geometry = require("./geometry.coffee")
Painter = require("./painter.coffee")

geometry = require("./geometry.coffee")
Point = geometry.Point
Vertex = geometry.Vertex
Segment = geometry.Segment
Polygon = geometry.Polygon
distanceOf = geometry.distanceOf
isPointInsidePoly = geometry.isPointInsidePoly
getRdians = geometry.getRdians

class Intersection
  constructor: (point, segA, segB, isOutward)->
    @point = point.clone()
    @segA = segA
    @segB = segB
    @isOutward = isOutward


segCastSeg = (segA, segB)->

  interPoint = geometry.getIntersection(segA, segB)
  if not interPoint then return null

  vecA = geometry.createVectorFrom2Points(segA.vertexA.point, segB.vertexA.point)
  vecInter = geometry.createVectorFrom2Points(segA.vertexA.point, segA.vertexB.point)
  isOutward = geometry.crossProduct(vecA, vecInter).z > 0

  return new Intersection(interPoint, segA, segB, isOutward)

outline = new Polygon([
  new Point(0, 0)
  new Point(640, 0)
  new Point(640, 480)
  new Point(0, 480)
])

#triangle = new Polygon([
#  new Point(120, 140)
#  new Point(520, 140)
#  new Point(320, 400)
#])
#
#square = new Polygon([
#  new Point(180, 100)
#  new Point(460, 100)
#  new Point(460, 340)
#  new Point(180, 340)
#])

triangle = new Polygon([
  new Point(120, 140)
  new Point(240, 100)
  new Point(520, 140)
  new Point(320, 400)
])

square = new Polygon([
  new Point(180, 100)
  new Point(460, 100)
  new Point(460, 340)
  new Point(300, 400)
  new Point(180, 340)
])

cutCastPoly = (cut, poly)->
  inters = []
  for cutVtx in cut.vertexes
    segInters = []
    for polyVtx in poly.vertexes
      inter = segCastSeg(cutVtx.segOut, polyVtx.segOut)
      if inter then segInters.push inter

    segInters.sort (a, b)->
      offset = a.segA.vertexB.point.x - a.segA.vertexA.point.x
      offsetA = (a.point.x - a.segA.vertexA.point.x) * offset
      offsetB = (b.point.x - a.segA.vertexA.point.x) * offset
      return offsetA - offsetB

    for segInter in segInters
      inters.push segInter

  return inters

visitA = (cut, poly, inters)->
  ints = []
  # 对于第一个碰撞点
  vtx = inters[0]
  cnt = 1000;
  # 找下一个点
  i = 0
  while i < inters.length
    cnt--
    if cnt is 0 then break
    ints.push vtx
    seg = null
    # 如果当前点是碰撞点
    if vtx instanceof Intersection
      # 如果是出点
      if vtx.isOutward
        # 当前直线为原直线
        seg = vtx.segB
      # 如果是入点
      else
        # 当前直线为切直线
        seg = vtx.segA
    # 如果当前点是拐角点
    else
      seg = vtx.segOut
    corner = seg.vertexB
    # 如果下一个交点在线上
    nextInter = inters[(i + 1) % inters.length]
    if nextInter and (nextInter.segA is seg or nextInter.segB is seg)
      # 如果碰撞点比下一个转角点近
      if distanceOf(seg.vertexA.point, corner.point) > distanceOf(seg.vertexA.point, nextInter.point)
        vtx = nextInter
        i++
      else
        vtx = corner
    else
      vtx = corner
  return ints

visitB = (cut, poly, inters)->
  ints = []
  for vtx in poly.vertexes
    if isPointInsidePoly vtx.point, cut
      ints.push vtx
  for vtx in cut.vertexes
    if isPointInsidePoly vtx.point, poly
      ints.push vtx
  for inter in inters
    ints.push inter

  totalX = 0
  totalY = 0
  for inter in ints
    totalX += inter.point.x
    totalY += inter.point.y

  center = new Point(totalX / inters.length, totalY / inters.length)
  for inter in ints
    inter.radians = getRdians(center, inter.point)

  ints.sort (a, b)-> return b.radians - a.radians

  return ints

painter = new Painter "wrapper", 640, 480
window.useVisitA = true

repaint = ()->
  painter.clear()
  painter.setColor("#888888")

  tri = triangle.offset(painter.getCursor().offset(new Point(-320, -240)))
  # tri = triangle.offset(new Point(-100, -100))

  painter.paintPolygon(outline)
  painter.paintPolygon(tri)
  painter.paintPolygon(square)

  inters = cutCastPoly(tri, square)

  if window.useVisitA
    ints = visitA(tri, square, inters)
  else
    ints = visitB(tri, square, inters)

  for inter in inters
    if inter.isOutward
      painter.setColor("#00ff00")
    else
      painter.setColor("#ff0000")
    painter.paintPoint(inter.point)

  for inter in ints
    painter.setColor("#0000ff")
    painter.paintPoint(inter.point)

  requestAnimationFrame(repaint)

repaint()