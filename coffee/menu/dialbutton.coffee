###
0000000    000   0000000   000        0000000    000   000  000000000  000000000   0000000   000   000
000   000  000  000   000  000        000   000  000   000     000        000     000   000  0000  000
000   000  000  000000000  000        0000000    000   000     000        000     000   000  000 0 000
000   000  000  000   000  000        000   000  000   000     000        000     000   000  000  0000
0000000    000  000   000  0000000    0000000     0000000      000        000      0000000   000   000
###

{ drag } = require 'kxk'

CanvasButton = require './canvasbutton'

class DialButton extends CanvasButton

    constructor: (div, clss) ->
    
        @lightPos = vec -4,4,6
        @camPos   = vec(0,0,1).normal().mul 10
        
        super div, clss
        
        @scene.background = Color.menu.background
        @name = 'DialButton'
        
        @drag = new drag
            target:  @canvas
            onStart: @onDrag
            onMove:  @onDrag
        
    setDial: (index) -> @update()

    # highlight: -> 
        # # @scene.background = Color.menu.backgroundHover
        # super
#     
    # unhighlight: ->
#         
        # # @scene.background = Color.menu.background
        # super
            
    initCamera: ->

        width = 11
        height = 11
        @camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, 1, 10
        
    initScene: ->
        
        super
        @initDots()
        
    initDots: ->
        
        merg = new THREE.Geometry
        
        for i in [-6..6]
            geom = Geometry.sphere 0.5
            geom.rotateX deg2rad 90
            p = vec(0,4,0).rotate vec(0,0,1), i*22.5
            geom.translate p.x, p.y, p.z
            merg.merge geom
        
        bufg = new THREE.BufferGeometry().fromGeometry merg
        mesh = new THREE.Mesh bufg, Materials.menu.inactive
        @scene.add mesh
        
        geom = Geometry.sphere 0.6
        geom.rotateX deg2rad 90
        bufg = new THREE.BufferGeometry().fromGeometry geom
        @dot = new THREE.Mesh bufg, Materials.menu.active
        @scene.add @dot
        
    onDrag: (drag, event) => 
        
        br = @canvas.getBoundingClientRect()
        
        ctr2Pos = vec(br.left+50, br.top+50).to drag.pos
        ctr2Pos.y = -ctr2Pos.y
        angle = Math.sign(ctr2Pos.dot(vec 1,0,0)) * ctr2Pos.angle(vec 0,1,0)
        sectn = clamp -6, 6, Math.round angle/22.5
        
        @setDial sectn
        
module.exports = DialButton
