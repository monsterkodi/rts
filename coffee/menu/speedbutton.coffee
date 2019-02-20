###
 0000000  00000000   00000000  00000000  0000000    0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  000       000       000   000  000   000  000   000     000        000     000   000  0000  000
0000000   00000000   0000000   0000000   000   000  0000000    000   000     000        000     000   000  000 0 000
     000  000        000       000       000   000  000   000  000   000     000        000     000   000  000  0000
0000000   000        00000000  00000000  0000000    0000000     0000000      000        000      0000000   000   000
###

{ post, drag, clamp, deg2rad, log } = require 'kxk'

Color        = require '../color' 
Geometry     = require '../geometry' 
Materials    = require '../materials'
CanvasButton = require './canvasbutton'

class SpeedButton extends CanvasButton

    constructor: (div) ->
    
        super div, 'speedButton canvasButtonInline'
        
        @name = 'SpeedButton'
        @scene.background = Color.menu.background
        
        post.on 'worldSpeed', @onWorldSpeed        
        
        @drag = new drag
            target:  @canvas
            onStart: @onDrag
            onMove:  @onDrag
        
        @onWorldSpeed()
            
    initScene: ->

        super()
        
        width = 11
        height = 11
        @camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, 1, 10
        
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
        
        @light.position.set -4,4,6
        @camera.position.copy vec(0,0,1).normal().mul 10
        @camera.lookAt vec 0,0,0
        
    onDrag: (drag, event) => 
        
        br = @canvas.getBoundingClientRect()
        
        ctr2Pos = vec(br.left+50, br.top+50).to drag.pos
        ctr2Pos.y = -ctr2Pos.y
        angle = Math.sign(ctr2Pos.dot(vec 1,0,0)) * ctr2Pos.angle(vec 0,1,0)
        sectn = clamp -6, 6, Math.round angle/22.5
        
        rts.world.setSpeed sectn+6
                
    onWorldSpeed: =>
        
        p = vec(0,4,0).rotate vec(0,0,1), 180-45-rts.world.speedIndex*22.5
        @dot.position.copy p
        @render()

module.exports = SpeedButton
