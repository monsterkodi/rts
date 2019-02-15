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
        @scene.background = new THREE.Color 0x181818
        
        @camera = new THREE.PerspectiveCamera 30, @width/@height, 0.01, 100
                
        @initScene()
        
    del: => @canvas.remove()
        
    render: ->

        # log 'render', @name
        CanvasButton.renderer.render @scene, @camera
        
        context = @canvas.getContext '2d'
        context.drawImage CanvasButton.renderer.domElement, 0, 0

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
    
    geomForCostRange: (stone, fromThousand, toThousand) ->
        
        return if fromThousand == toThousand
        
        from = Math.floor fromThousand/10
        to   = Math.floor   toThousand/10
        
        if from == to
            to += 1
        
        merg = new THREE.Geometry 
        
        l = Math.floor from/10
        h = Math.floor to/10
        
        trans = (geom,h,y,f) ->
            geom.translate -0.25 + (1<f<4 and 0.5 or 0),(h*1.2)+0.25+(y>4 and 0.5 or 0), -0.25 + (f>2 and 0.5 or 0)
        
        if (from%10) > 0
             
            for y in [from%10..9]
                f = y%5
                continue if f == 0
                geom = new THREE.BoxGeometry 0.5,0.5,0.5
                trans geom,l,y,f
                merg.merge geom
                
            l += 1
        
        for y in [l...h]
            geom = new THREE.BoxGeometry 1,1,1
            geom.translate 0,(y*1.2)+0.5,0
            merg.merge geom
        
        if to%10 > 0
            for y in [1..to%10]
                f = y%5
                continue if f == 0
                geom = new THREE.BoxGeometry 0.5,0.5,0.5
                trans geom,h,y,f
                merg.merge geom
                
        merg.translate stone*1.5-2.3, 0, 0 
            
        new THREE.BufferGeometry().fromGeometry merg
        
module.exports = CanvasButton
