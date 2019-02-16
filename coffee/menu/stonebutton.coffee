###
 0000000  000000000   0000000   000   000  00000000  0000000    000   000  000000000  000000000   0000000   000   000
000          000     000   000  0000  000  000       000   000  000   000     000        000     000   000  0000  000
0000000      000     000   000  000 0 000  0000000   0000000    000   000     000        000     000   000  000 0 000
     000     000     000   000  000  0000  000       000   000  000   000     000        000     000   000  000  0000
0000000      000      0000000   000   000  00000000  0000000     0000000      000        000      0000000   000   000
###

{ post, log, _ } = require 'kxk'

{ Stone } = require '../constants'
Materials = require '../materials'

CanvasButton = require './canvasbutton'

class StoneButton extends CanvasButton

    constructor: (div, stone, inOut, clss='stoneButton buttonCanvas') ->

        super div, clss

        @stone  = stone
        @inOut  = inOut
        
        @name = "StoneButton #{Stone.string stone}"
        
        @camera.updateProjectionMatrix()
        @render()
        
    amount: -> 
        if @inOut == 'buy' then return 1
        state.science.trade.sell
        
    click: -> post.emit @inOut, @stone
    
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
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
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        @meshes.stone?.parent.remove @meshes.stone
        delete @meshes.stone

        bufg = @geomForTrade @stone, @amount()
        mesh = new THREE.Mesh bufg, Materials.cost[@stone]
        @scene.add mesh
        @meshes.stone = mesh
            
        super()
        
module.exports = StoneButton
