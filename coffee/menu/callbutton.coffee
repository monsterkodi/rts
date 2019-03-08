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
        
        @normFov = 40
        @camPos = vec(0,0,1).normal().mul 2
        
        super div, 'canvasButtonInline'
        
    click: -> rts.handle.call()

    initScene: ->
        
        @scene.add @meshes.icon = new THREE.Mesh Geometry.call(), Materials.menu.active
        
module.exports = CallButton
