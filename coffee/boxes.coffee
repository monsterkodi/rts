###
0000000     0000000   000   000  00000000   0000000
000   000  000   000   000 000   000       000     
0000000    000   000    00000    0000000   0000000 
000   000  000   000   000 000   000            000
0000000     0000000   000   000  00000000  0000000 
###

require('three-instanced-mesh')(THREE)

class Boxes

    constructor: (scene, @maxBoxes=1000, geom=Geometry.cornerBox(), material=Materials.white, shadows=true) ->

        @boxes = []
        @sz = vec()
        @cluster = new THREE.InstancedMesh geom, material, @maxBoxes, true, true, true
        
        if shadows
            @cluster.receiveShadow = true
            @cluster.castShadow    = true
            
        scene.add @cluster 
        
    numBoxes: -> @boxes.length
    lastBox:  -> @boxes[@lastIndex()]
    lastIndex: -> @numBoxes()-1
        
    setStone: (box, stone) -> @setColor box, Color.stones[stone]
    setDir:   (box, dir)   -> @setRot box, quat().setFromUnitVectors Vector.unitZ, dir
    setPos:   (box, pos)   -> @cluster.setPositionAt   box.index, pos
    setRot:   (box, rot)   -> @cluster.setQuaternionAt box.index, rot
    setColor: (box, color) -> @cluster.setColorAt      box.index, color
    setSize:  (box, size)  -> 
        @sz.x = size 
        @sz.y = size 
        @sz.z = size 
        @cluster.setScaleAt box.index, @sz
    
    pos:   (box,pos=vec())  -> @cluster.getPositionAt box.index, pos; pos
    rot:   (box,rot=quat()) -> @cluster.getQuaternionAt box.index, rot; rot
    size:  (box,szv=vec())  -> @cluster.getScaleAt box.index, szv; szv.x
    color: (box,color=new THREE.Color()) -> @cluster.getColorAt box.index, color; color
    
    add: (cfg) ->
        
        box = index:@numBoxes()
        
        @boxes.push box
        
        if cfg.pos
            @setPos box, cfg.pos
        else
            @sz.set 0,0,0
            @setPos box, @sz
        if cfg.color?
            @setColor box, cfg.color
        else
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
        
        if not box?
            
            @cluster?.parent.remove @cluster
            delete @cluster
            return
        
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
            
        @cluster.needsUpdate()
        
    render: ->

        @cluster.needsUpdate() if @numBoxes()

module.exports = Boxes
