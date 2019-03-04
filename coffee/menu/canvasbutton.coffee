###
 0000000   0000000   000   000  000   000   0000000    0000000  0000000    000   000  000000000  000000000   0000000   000   000
000       000   000  0000  000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
000       000000000  000 0 000   000 000   000000000  0000000   0000000    000   000     000        000     000   000  000 0 000
000       000   000  000  0000     000     000   000       000  000   000  000   000     000        000     000   000  000  0000
 0000000  000   000  000   000      0      000   000  0000000   0000000     0000000      000        000      0000000   000   000
###

class CanvasButton
    
    @renderer = null

    constructor: (div, clss='canvasButton') ->
        
        @width     = 100
        @height    = 100
        @stoneSize = 0.5
        
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
        @scene.background = Color.menu.backgroundHover
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 100
                
        @initScene()
        
        @camera.updateProjectionMatrix() 
        
    del: => @canvas.remove()
    
    initLight: ->

        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff

    initScene: ->

        @initLight()
        
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
        
    render: =>

        CanvasButton.renderer.render @scene, @camera
        
        context = @canvas.getContext '2d'
        context.drawImage CanvasButton.renderer.domElement, 0, 0
        
    posForStone: (stone, i) ->
        
        pos = vec()
        pos.x = stone*1.5-2.5
        pos.y = 1.2*Math.floor (i-1)/8
        pos.x += @stoneSize if (i-1)%4 in [1,2]
        pos.z += @stoneSize if (i-1)%4 in [2,3]
        pos.y += @stoneSize if (i-1)%8 > 3
        pos
        
module.exports = CanvasButton
