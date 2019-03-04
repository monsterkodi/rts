###
 0000000   0000000   000      000      0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  000      000      000   000  000   000     000        000     000   000  0000  000
000       000000000  000      000      0000000    000   000     000        000     000   000  000 0 000
000       000   000  000      000      000   000  000   000     000        000     000   000  000  0000
 0000000  000   000  0000000  0000000  0000000     0000000      000        000      0000000   000   000
###

CanvasButton = require './canvasbutton'

class CallButton extends CanvasButton

    constructor: (div) ->
        
        super div, 'canvasButtonInline'
        
        @render()
        
    click: -> rts.handle.call()

    initScene: ->
        
        @initLight()
        
        @camera.fov = 40
        @camera.position.copy vec(0,0,1).normal().mul 2
        @camera.lookAt vec 0,0,0
        
        mat = Materials.menu.active
        mesh = new THREE.Mesh Geometry.call(), mat
        @scene.add @meshes.icon = mesh
        
module.exports = CallButton
