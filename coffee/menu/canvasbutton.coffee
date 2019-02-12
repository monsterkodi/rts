###
 0000000   0000000   000   000  000   000   0000000    0000000  0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  0000  000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
000       000000000  000 0 000   000 000   000000000  0000000   0000000    000   000     000        000     000   000  000 0 000
000       000   000  000  0000     000     000   000       000  000   000  000   000     000        000     000   000  000  0000
 0000000  000   000  000   000      0      000   000  0000000   0000000     0000000      000        000      0000000   000   000
###

{ elem, empty, log, _ } = require 'kxk'

class CanvasButton
    
    @renderer = null

    constructor: (div, clss='buttonCanvas') ->
        
        @width  = 100
        @height = 100
        
        @meshes = {}
        
        fullWidth  = 2 * @width 
        fullHeight = 2 * @height
        
        if empty CanvasButton.renderer
            CanvasButton.renderer = new THREE.WebGLRenderer antialias:true
            CanvasButton.renderer.setPixelRatio window.devicePixelRatio
            CanvasButton.renderer.setSize @width, @height

        @canvas = elem 'canvas', class:clss, width:@width*window.devicePixelRatio, height:@height*window.devicePixelRatio
        div.appendChild @canvas
                
        @scene = new THREE.Scene()
        @scene.background = new THREE.Color 0x181818
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 100
                
        @initScene()
        
    del: => @canvas.remove()
        
    render: ->

        CanvasButton.renderer.render @scene, @camera
        
        context = @canvas.getContext '2d'
        context.drawImage CanvasButton.renderer.domElement, 0, 0

module.exports = CanvasButton
