###
000   000  00000000   0000000  000000000   0000000   00000000 
000   000  000       000          000     000   000  000   000
 000 000   0000000   000          000     000   000  0000000  
   000     000       000          000     000   000  000   000
    0      00000000   0000000     000      0000000   000   000
###

{ deg2rad, rad2deg, last, log } = require 'kxk'

THREE = require 'three'

class Vector extends THREE.Vector3

    constructor: (x=0,y=0,z=0) ->
        if x.x? and x.y?
            super x.x, x.y, x.z ? 0
        else if Array.isArray x
            super x[0], x[1], x[2] ? 0
        else
            super x, y, z ? 0
        if Number.isNaN @x
            throw new Error
            
    clone: -> new Vector @
    copy: (v) -> 
        @x = v.x
        @y = v.y 
        @z = v.z ? 0
        @

    normal: -> @clone().normalize()
    
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
        
    rotate: (axis, angle) ->
        @applyQuaternion quat().setFromAxisAngle axis, deg2rad angle
        @

    rotated: (axis, angle) -> @clone().rotate axis,angle
        
    cross: (v) -> @clone().crossVectors(@,v)
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
    equals: (o) -> @manhattan(o) < 0.001
    same:   (o) -> @x==o.x and @y==o.y and z=o.z

    fade: (o, val) -> # linear interpolation from this (val==0) to other (val==1)
        
        @x = @x * (1-val) + o.x * val
        @y = @y * (1-val) + o.y * val
        @z = @z * (1-val) + o.z * val
        @
        
    faded: (o, val) -> @clone().fade o, val
    
    xyangle: (v) ->
        
        thisXY  = new Vector(@x, @y).normal()
        otherXY = new Vector(v.x, v.y).normal()
        if thisXY.xyperp().dot otherXY >= 0 
            return rad2deg(Math.acos(thisXY.dot otherXY))
        -rad2deg(Math.acos(thisXY.dot otherXY))
        
    paris: (o) -> 
        m = [Math.abs(o.x-@x),Math.abs(o.y-@y),Math.abs(o.z-@z)]
        m.sort (a,b) -> b-a
        m[0]+0.2*m[1]+0.1*m[2]
    
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
        
    negate:  -> @scale -1
    scale: (f) ->
        @x *= f
        @y *= f
        @z *= f
        @
        
    reset: ->
        @x = @y = @z = 0
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
    
    @closestNormal: (v) ->
        vn = v.normal()
        angles = []
        for n in Vector.normals
            if n.equals vn
                return n
            angles.push [n.angle(vn), n]
                
        angles.sort (a,b) -> a[0]-b[0]
        angles[0][1]
    
module.exports = Vector
