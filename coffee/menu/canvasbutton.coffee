###
 0000000   0000000   000   000  000   000   0000000    0000000  0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  0000  000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
000       000000000  000 0 000   000 000   000000000  0000000   0000000    000   000     000        000     000   000  000 0 000
000       000   000  000  0000     000     000   000       000  000   000  000   000     000        000     000   000  000  0000
 0000000  000   000  000   000      0      000   000  0000000   0000000     0000000      000        000      0000000   000   000
###

{ elem, empty, log, _ } = require 'kxk'

{ Stone } = require '../constants'

Color = require '../color'

class CanvasButton
    
    @renderer = null

    constructor: (div, clss='canvasButton') ->
        
        @width  = 100
        @height = 100
        
        @name = 'canvasbutton'
        
        @meshes = {}
        
        fullWidth  = 2 * @width 
        fullHeight = 2 * @height
        
        if empty CanvasButton.renderer
            CanvasButton.renderer = new THREE.WebGLRenderer antialias:true
            CanvasButton.renderer.setPixelRatio window.devicePixelRatio
            CanvasButton.renderer.setSize @width, @height

        @canvas = elem 'canvas', class:clss, width:@width*window.devicePixelRatio, height:@height*window.devicePixelRatio
        div.appendChild @canvas
        
        @canvas.button = @        
        @scene = new THREE.Scene()
        @scene.background = Color.menu.background
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 100
                
        @initScene()
        
        @camera.updateProjectionMatrix() 
        
    del: => @canvas.remove()

    initScene: ->
                
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0.3,0.6,1).normal().mul 12
        @camera.lookAt vec 0,0,0
    
    highlight: -> 

        @camera.fov = 33
        @camera.updateProjectionMatrix()
        @render()
    
    unhighlight: ->

        @camera.fov = 40
        @camera.updateProjectionMatrix()
        @render()
        
    render: ->

        CanvasButton.renderer.render @scene, @camera
        
        context = @canvas.getContext '2d'
        context.drawImage CanvasButton.renderer.domElement, 0, 0
        
module.exports = CanvasButton
