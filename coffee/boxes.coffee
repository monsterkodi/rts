###
0000000     0000000   000   000  00000000   0000000
000   000  000   000   000 000   000       000     
0000000    000   000    00000    0000000   0000000 
000   000  000   000   000 000   000            000
0000000     0000000   000   000  00000000  0000000 
###

{ last, log } = require 'kxk'

{ Stone } = require './constants'

THREE = require 'three'
require('three-instanced-mesh')(THREE)

Color     = require './color'
Geometry  = require './geometry'
Materials = require './materials'

class Boxes

    constructor: (scene, @maxBoxes=50000, geom=Geometry.cornerBox()) ->

        @boxes = []
        @cluster = new THREE.InstancedMesh geom, Materials.white, @maxBoxes, true, true, true
        
        @cluster.receiveShadow = true
        @cluster.castShadow = true
        scene.add @cluster 
        
    numBoxes: -> @boxes.length
    lastBox:  -> @boxes[@lastIndex()]
    lastIndex: -> @numBoxes()-1
        
    setStone: (box, stone) -> @setColor box, Color.stones[stone]
    setDir:   (box, dir)   -> @setRot box, quat().setFromUnitVectors vec(0,0,1), vec(dir).normal()
    setPos:   (box, pos)   -> @cluster.setPositionAt   box.index, vec pos
    setRot:   (box, rot)   -> @cluster.setQuaternionAt box.index, rot
    setSize:  (box, size)  -> @cluster.setScaleAt      box.index, vec size, size, size
    setColor: (box, color) -> @cluster.setColorAt      box.index, color
    
    pos:   (box) -> pos = vec();  @cluster.getPositionAt box.index, pos; pos
    rot:   (box) -> rot = quat(); @cluster.getQuaternionAt box.index, rot; rot
    size:  (box) -> szv = vec();  @cluster.getScaleAt box.index, szv; szv.x
    color: (box) -> color = new THREE.Color(); @cluster.getColorAt box.index, color; color
    
    add: (cfg) ->
        
        box = index:@numBoxes()
        
        @boxes.push box
        
        @setPos   box, cfg.pos
        @setStone box, cfg.stone ? Stone.gray
        @setSize  box, cfg.size ? 0.1
        if cfg.dir?
            @setDir box, cfg.dir 
        else if cfg.rot?
            @setRot box, cfg.rot 
        else
            @setRot box, quat()
        
        box
        
    del: (box) ->
        
        if box.index < @lastIndex()
            lastBox = @boxes.pop()
            pos     = @pos   lastBox
            rot     = @rot   lastBox
            size    = @size  lastBox
            color   = @color lastBox
            @setSize lastBox, 0
            @boxes[box.index] = lastBox
            lastBox.index = box.index
            @setPos   lastBox, pos
            @setRot   lastBox, rot
            @setSize  lastBox, size
            @setColor lastBox, color
            
        else if box.index == @lastIndex()
            lastBox = @boxes.pop()
            @setSize lastBox, 0
        else
            log "Boxes.del dafuk? #{box.index} #{@lastIndex()}"
        
    render: ->

        @cluster.needsUpdate() if @numBoxes()

module.exports = Boxes
