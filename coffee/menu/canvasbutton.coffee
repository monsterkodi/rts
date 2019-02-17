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

    constructor: (div, clss='buttonCanvas') ->
        
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
        @scene.background = Color.menu.backgroundHover
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 100
                
        @initScene()
        
    del: => @canvas.remove()

    initScene: ->
                
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0.3,0.6,1).normal().mul 12
        @camera.lookAt vec 0,0,0
        @camera.updateProjectionMatrix()
    
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

    #  0000000  000000000   0000000   000000000  00000000  
    # 000          000     000   000     000     000       
    # 0000000      000     000000000     000     0000000   
    #      000     000     000   000     000     000       
    # 0000000      000     000   000     000     00000000  
    
    geomForState: (state) ->
        
        switch state
            when 'off'  
                geom = new THREE.Geometry
                geom.vertices.push vec -1.5,  2,  1.5
                geom.vertices.push vec -1.5, -2,  1.5
                geom.vertices.push vec  2.0,  0,  1.5
                geom.vertices.push vec -1.5,  2,  0
                geom.vertices.push vec  2.0,  0,  0
                geom.faces.push new THREE.Face3 0, 1, 2
                geom.faces.push new THREE.Face3 3, 0, 4
                geom.faces.push new THREE.Face3 0, 2, 4
                geom.computeFaceNormals()
                geom.computeFlatVertexNormals()
                
            when 'on' 
                left  = new THREE.BoxGeometry 2,4,1.5
                left.translate -1.5, 0, 0     
                right = new THREE.BoxGeometry 2,4,1.5
                right.translate 1.5, 0, 0
                geom  = new THREE.Geometry
                geom.merge left
                geom.merge right
            else
                geom = new THREE.BoxGeometry 1.8,1.8,1.8
                
        new THREE.BufferGeometry().fromGeometry geom
        
    # 000000000  00000000    0000000   0000000    00000000  
    #    000     000   000  000   000  000   000  000       
    #    000     0000000    000000000  000   000  0000000   
    #    000     000   000  000   000  000   000  000       
    #    000     000   000  000   000  0000000    00000000  
    
    geomForTrade: (stone, amount) ->
        
        return if amount <= 0
        
        merg = new THREE.Geometry 
        
        for i in [0...amount]
            geom = new THREE.BoxGeometry 1.8,1.8,1.8
            switch amount
                when 1 then
                when 2
                    switch i
                        when 0 then geom.translate -1, 0, 0
                        when 1 then geom.translate  1, 0, 0
                else
                    switch i
                        when 0 then geom.translate -1, -1, 0
                        when 1 then geom.translate  1, -1, 0
                        when 2 then geom.translate  1,  1, 0
                        when 3 then geom.translate -1,  1, 0
            merg.merge geom
            
        new THREE.BufferGeometry().fromGeometry merg
        
    #  0000000   0000000    0000000  000000000  
    # 000       000   000  000          000     
    # 000       000   000  0000000      000     
    # 000       000   000       000     000     
    #  0000000   0000000   0000000      000     
    
    
    smallGeom: (h,y) ->
        geom = new THREE.BoxGeometry 0.5,0.5,0.5
        f = (y-1)%4
        geom.translate -0.25 + (0<f<3 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (f>1 and 0.5 or 0)
        geom
    
    geomForStonesMissing: (stone, have, cost) ->
        
        ceil  = 8*Math.ceil have/8
        small = ceil-have
            
        merg = new THREE.Geometry 
        @geomForStoneAmount stone, cost-ceil, merg
        merg.translate 0, ceil/8*1.2, 0
            
        if small
            for y in [9-small..8]
                geom = @smallGeom ceil/8-1, y
                geom.translate stone*1.5-2.3,0,0
                merg.merge geom
                
        new THREE.BufferGeometry().fromGeometry merg
    
    geomForStoneAmount: (stone, amount, mergeWith) ->
        
        return if amount == 0
        
        merg  = new THREE.Geometry 
        
        big   = Math.floor amount/8
        small = amount - big*8
        
        for y in [0...big]
            geom = new THREE.BoxGeometry 1,1,1
            geom.translate 0,(y*1.2)+0.5,0
            merg.merge geom
        
        if small
            for y in [1..small%8]
                merg.merge @smallGeom big,y
                
        merg.translate stone*1.5-2.3, 0, 0 
            
        if mergeWith
            mergeWith.merge merg
            mergeWith
        else
            new THREE.BufferGeometry().fromGeometry merg
        
module.exports = CanvasButton
