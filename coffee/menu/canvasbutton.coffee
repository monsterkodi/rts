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
        
        @highlighted = false
        
        @width     = 100
        @height    = 100
        @size      = vec @width*window.devicePixelRatio, @height*window.devicePixelRatio
        @stoneSize = 0.5
        
        @name = 'CanvasButton'
        
        @meshes = {}
        
        if empty CanvasButton.renderer
            CanvasButton.renderer = new THREE.WebGLRenderer antialias:true
            CanvasButton.renderer.setPixelRatio window.devicePixelRatio
            CanvasButton.renderer.setSize @width, @height

        @canvas = elem 'canvas', class:clss, width:@size.x, height:@size.y
        div.appendChild @canvas
        
        @canvas.button = @        
        @scene = new THREE.Scene()
        @scene.background = Color.menu.backgroundHover
        
        @highFov  ?= 33
        @normFov  ?= 40
        @lightPos ?= vec 0,10,6
        @lookPos  ?= vec 0,0,0
        @camPos   ?= vec(0.3,0.6,1).normal().mul 12
        
        @initCamera()
        
        @camera.position.copy @camPos
        @camera.lookAt @lookPos
        @camera.updateProjectionMatrix() 
        
        @initLight()
        @initScene()
        
        @dirty = true
        
    del: => @canvas.remove()
    
    initLight: ->

        @light = new THREE.DirectionalLight 0xffffff
        @light.position.copy @lightPos
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff

    initCamera: ->
        
        @camera = new THREE.PerspectiveCamera @normFov, @width/@height, 0.01, 100
        
    initScene: -> 
    
    # 000   000  000   0000000   000   000  000      000   0000000   000   000  000000000  
    # 000   000  000  000        000   000  000      000  000        000   000     000     
    # 000000000  000  000  0000  000000000  000      000  000  0000  000000000     000     
    # 000   000  000  000   000  000   000  000      000  000   000  000   000     000     
    # 000   000  000   0000000   000   000  0000000  000   0000000   000   000     000     
    
    highlight: -> 
        
        @highlighted = true
        @camera.fov = @highFov
        @camera.updateProjectionMatrix()
        @update()
    
    unhighlight: ->
        
        @highlighted = false
        @camera.fov = @normFov
        @camera.updateProjectionMatrix()
        @update()
        
    update: => 
        # log "update #{@name}"
        @dirty = true
        
    animate: (delta) ->
        
        if @dirty then @render()
    
    render: =>
        
        if @dirty
        
            @dirty = false
            
            # log "render #{@name}"
            
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
