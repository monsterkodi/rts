###
0000000    000   000  000   000 
000   000  000   000   000 000  
0000000    000   000    00000   
000   000  000   000     000    
0000000     0000000      000    
###

CanvasButton = require './canvasbutton'
Boxes        = require '../boxes'

class BuyButton extends CanvasButton

    constructor: (@botButton, div) ->
        
        div ?= @botButton.canvas.parentElement
        
        super div, 'buyButton'
        
        @bot = @botButton.bot
        
        @name = "BuyButton #{Bot.string @bot}"
        
        y = @botButton.canvas.offsetTop - rts.menuBorderWidth
        @canvas.style = "left:100px; top:#{y}px"
        
        @boxes = new Boxes @scene, 160, new THREE.BoxBufferGeometry
        @box   = [[],[],[],[]]
        
        @init()
        
        post.on 'storageChanged', @onStorageChanged
        
        @canvas.addEventListener 'mouseout', @del
        
    init: ->
        
        cost = @cost()
        have = rts.world.storage[0].stones
        
        for stone in Stone.resources
            
            while @box[stone].length < cost[stone]
                stoneOrNot = stone
                if @box[stone].length >= have[stone]
                    stoneOrNot = Stone.gray
                @box[stone].push @boxes.add stone:stoneOrNot, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1
                
        @render()
                        
    update: -> 
        
        have = rts.world.storage[0].stones
        
        for stone in Stone.resources
            
            for i in [0...@box[stone].length]
                stoneOrNot = stone
                if i >= have[stone]
                    stoneOrNot = Stone.gray
                @boxes.setStone @box[stone][i], stoneOrNot
        
        @render()
                
    del: ->
        
        @boxes?.del()
        delete @boxes
        @canvas.removeEventListener 'mouseout', @del        
        post.removeListener 'storageChanged', @onStorageChanged
        super()
        
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
        @camera.position.copy vec(0,1,1).normal().mul 14
        @camera.lookAt vec 0,3,0
        @camera.updateProjectionMatrix()
        
    highlight: -> 

        return if not @canAfford()
        
        @camera.fov = 33
        @camera.updateProjectionMatrix()
        @render()
    
    unhighlight: ->
        
        @camera.fov = 40
        @camera.updateProjectionMatrix()
        @render()
        
    click: -> rts.handle.buyButtonClick @
                    
    canAfford: -> rts.world.storage[0].canAfford @cost()
    cost: -> config.cost[Bot.string @bot]
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    onStorageChanged: (storage, stone, amount) => 
        
        return if storage.player != 0
        @update()
    
    render: ->

        @boxes?.render()        
        super()
                            
module.exports = BuyButton
