###
000   000  00000000   0000000  000000000   0000000   00000000 
000   000  000       000          000     000   000  000   000
 000 000   0000000   000          000     000   000  0000000  
   000     000       000          000     000   000  000   000
    0      00000000   0000000     000      0000000   000   000
###

{ rad2deg, log } = require 'kxk'

class Vector

    constructor: (x=0,y=0,z=0) ->
        if x.x? and x.y?
            @copy x
        else if Array.isArray x
            @x = x[0]
            @y = x[1]
            @z = x[2] ? 0
        else
            @x = x
            @y = y
            @z = z ? 0
        if Number.isNaN @x
            throw new Error
            
    clone: -> new Vector @
    copy: (v) -> 
        @x = v.x
        @y = v.y 
        @z = v.z ? 0
        @

    normal: -> new Vector(@).normalize()
    
    parallel: (n) ->
        dot = @x*n.x + @y*n.y + @z*n.z
        new Vector dot*n.x, dot*n.y, dot*n.z

    # returns the projection of normalized vector n to vector that is perpendicular to this
    perpendicular: (n) ->
        dot = @x*n.x + @y*n.y + @z*n.z
        new Vector @x-dot*n.x, @y-dot*n.y, @z-dot*n.z 

    reflect: (n) ->
        dot = 2*(@x*n.x + @y*n.y + @z*n.z)
        new Vector @x-dot*n.x, @y-dot*n.y, @z-dot*n.z

    cross: (v) -> new Vector @y*v.z-@z*v.y, @z*v.x-@x*v.z, @x*v.y-@y*v.x
    normalize: ->
        l = @length()
        if l
            l = 1.0/l
            @x *= l
            @y *= l
            @z *= l
        @    

    xyperp: -> new Vector -@y, @x
    round:  -> new Vector Math.round(@x), Math.round(@y), Math.round(@z)
    equals: (o) -> @x==o.x and @y==o.y and z=o.z

    fade: (o, val) ->
        @x = @x * (1-val) + o.x * val
        @y = @y * (1-val) + o.y * val
        @z = @z * (1-val) + o.z * val
    
    xyangle: (v) ->
        thisXY  = new Vector(@x, @y).normal()
        otherXY = new Vector(v.x, v.y).normal()
        if thisXY.xyperp().dot otherXY >= 0 
            return rad2deg(Math.acos(thisXY.dot otherXY))
        -rad2deg(Math.acos(thisXY.dot otherXY))

        
    manhattan: (o) -> Math.abs(o.x-@x)+Math.abs(o.y-@y)+Math.abs(o.z-@z)
    dist:   (o) -> @minus(o).length()
    length:    -> Math.sqrt @x*@x + @y*@y + @z*@z
    angle: (v) -> rad2deg Math.acos @normal().dot v.normal()
    dot:   (v) -> @x*v.x + @y*v.y + @z*v.z
    
    mul:   (f) -> new Vector @x*f, @y*f, @z*f
    div:   (d) -> new Vector @x/d, @y/d, @z/d
    plus:  (v) -> new Vector(v).add @
    minus: (v) -> new Vector(v).neg().add @
    neg:       -> new Vector -@x, -@y, -@z
    to:    (v) -> new Vector(v).sub @
     
    add: (v) ->
        @x += v.x 
        @y += v.y 
        @z += v.z ? 0
        @
    
    sub: (v) ->
        @x -= v.x 
        @y -= v.y 
        @z -= v.z ? 0
        @
    
    scale: (f) ->
        @x *= f
        @y *= f
        @z *= f
        @
        
    reset: ->
        @x = @y = @z =
        @
    
    isZero: -> @x == @y == @z == 0

    @rayPlaneIntersection: (rayPos, rayDirection, planePos, planeNormal) ->
        x = planePos.minus(rayPos).dot(planeNormal) / rayDirection.dot(planeNormal)
        return rayPos.plus rayDirection.mul x

    @pointMappedToPlane: (point, planePos, planeNormal) ->
        point.minus(planeNormal).dot point.minus(planePos).dot(planeNormal)

    @rayPlaneIntersectionFactor: (rayPos, rayDir, planePos, planeNormal) ->
        rayDot = rayDir.dot planeNormal
        if Number.isNaN rayDot
            throw new Error
        return 2 if rayDot == 0
        r = planePos.minus(rayPos).dot(planeNormal) / rayDot
        if Number.isNaN r
            log 'rayPos', rayPos
            log 'rayDir', rayDir
            log 'planePos', planePos
            log 'planeNormal', planeNormal
            throw new Error
        r

    @PX = 0
    @PY = 1
    @PZ = 2
    @NX = 3
    @NY = 4
    @NZ = 5
        
    @unitX  = new Vector 1,0,0
    @unitY  = new Vector 0,1,0
    @unitZ  = new Vector 0,0,1
    @minusX = new Vector -1,0,0
    @minusY = new Vector 0,-1,0
    @minusZ = new Vector 0,0,-1
    
    @normals = [Vector.unitX, Vector.unitY, Vector.unitZ, Vector.minusX, Vector.minusY, Vector.minusZ]
    
module.exports = Vector