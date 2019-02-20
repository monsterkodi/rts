###
 0000000  00000000   00000000  00000000  0000000    0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  000       000       000   000  000   000  000   000     000        000     000   000  0000  000
0000000   00000000   0000000   0000000   000   000  0000000    000   000     000        000     000   000  000 0 000
     000  000        000       000       000   000  000   000  000   000     000        000     000   000  000  0000
0000000   000        00000000  00000000  0000000    0000000     0000000      000        000      0000000   000   000
###

{ clamp, deg2rad, log } = require 'kxk'

Color        = require '../color' 
Geometry     = require '../geometry' 
Materials    = require '../materials'
CanvasButton = require './canvasbutton'

class SpeedButton extends CanvasButton

    constructor: (div) ->
    
        super div, 'speedButton canvasButtonInline'
        
        @name = 'SpeedButton'
        @scene.background = Color.menu.background
        
        @canvas.addEventListener 'click', @onClick
                
        @render()

    initScene: ->

        super()
        
        width = 11
        height = 11
        @camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, 1, 10
        
        merg = new THREE.Geometry
        
        for i in [-3..3]
            geom = Geometry.sphere 0.5
            geom.rotateX deg2rad 90
            p = vec(0,4,0).rotate vec(0,0,1), i*45
            geom.translate p.x, p.y, p.z
            merg.merge geom
        
        bufg = new THREE.BufferGeometry().fromGeometry merg
        mesh = new THREE.Mesh bufg, Materials.menu.inactive
        
        @scene.add mesh
        @light.position.set -4,4,6
        @camera.position.copy vec(0,0,1).normal().mul 10
        @camera.lookAt vec 0,0,0
        
    onClick: (event) -> 
        
        ctr2Pos = vec(50, 50).to vec event.offsetX, 100-event.offsetY
        angle = Math.sign(ctr2Pos.dot(vec 1,0,0)) * ctr2Pos.angle(vec 0,1,0)
        sectn = clamp -3, 3, Math.round angle/45
        log 'sectn', sectn

module.exports = SpeedButton
