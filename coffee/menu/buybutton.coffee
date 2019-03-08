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

    constructor: (@menu) ->
        
        @lightPos = vec 0,10,6
        @camPos   = vec(0,1,1).normal().mul 14
        @lookPos  = vec 0,3,0
        
        @normFov = 40
        @highFov = 33
        
        super @menu.div, 'buyButton'
        
        @bot = @menu.botButton.bot
        
        @name = "BuyButton #{Bot.string @bot}"
        
        @boxes = new Boxes @scene, 160, new THREE.BoxBufferGeometry
        @box   = [[],[],[],[]]
        
        @init()
        
        post.on 'storageChanged', @onStorageChanged
        
    init: ->
        
        cost = @cost()
        have = rts.world.storage[0].stones
        
        for stone in Stone.resources
            
            while @box[stone].length < cost[stone]
                stoneOrNot = stone
                if @box[stone].length >= have[stone]
                    stoneOrNot = Stone.gray
                @box[stone].push @boxes.add stone:stoneOrNot, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1
                
    update: -> 
        
        return if not @boxes
        
        have = rts.world.storage[0].stones
        
        for stone in Stone.resources
            
            for i in [0...@box[stone].length]
                stoneOrNot = stone
                if i >= have[stone]
                    stoneOrNot = Stone.gray
                @boxes.setStone @box[stone][i], stoneOrNot
        
        super
                
    del: ->
        
        @boxes?.del()
        delete @boxes
        @canvas.removeEventListener 'mouseout', @del        
        post.removeListener 'storageChanged', @onStorageChanged
        super
        
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
            
    highlight: -> 

        return if not @canAfford()

        playSound 'menu', 'highlight', @bot+1

        super
            
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
        super
                            
module.exports = BuyButton
