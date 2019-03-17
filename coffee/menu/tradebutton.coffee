###
000000000  00000000    0000000   0000000    00000000  0000000    000   000  000000000  000000000   0000000   000   000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  0000  000
   000     0000000    000000000  000   000  0000000   0000000    000   000     000        000     000   000  000 0 000
   000     000   000  000   000  000   000  000       000   000  000   000     000        000     000   000  000  0000
   000     000   000  000   000  0000000    00000000  0000000     0000000      000        000      0000000   000   000
###

CanvasButton = require './canvasbutton'

class TradeButton extends CanvasButton

    TradeButton.sell = null
    TradeButton.buy  = null
    
    constructor: (@menu, @inOut, @stone) ->
        
        @highFov  = 33
        @normFov  = 40
        @lightPos = vec 0,10,6
        @camPos   = vec(0.3,0.6,1).normal().mul 12
        
        @stone ?= world.botOfType(Bot.trade)[@inOut]
        
        super @menu.div, 'tradeButton canvasButtonInline'
        
        @name = "TradeButton #{@inOut} #{Stone.string @stone}"
        
        TradeButton[@inOut] = @
        
        post.on 'scienceFinished', @onScienceFinished
                
    del: ->

        post.removeListener 'scienceFinished', @onScienceFinished
        super 
                
    onScienceFinished: (info) =>
        
        if info.scienceKey == 'trade.sell' and @inOut == 'sell'
            @update()
                
    highlight: ->

        playSound 'stone', 'highlight', @stone
        @menu.highlight @
        super 
        
    unhighlight: ->
        
        @menu.unhighlight @
        super
        
    amount: ->
        
        if @inOut == 'buy' then return 1
        science().trade.sell
        
    click: -> @menu.buttonClicked @
    
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        return if not @dirty
        
        @meshes.stone?.parent.remove @meshes.stone
        delete @meshes.stone

        bufg = Geometry.trade @stone, @amount()
        mesh = new THREE.Mesh bufg, Materials.cost[@stone]
        @scene.add mesh
        @meshes.stone = mesh
            
        super
        
module.exports = TradeButton
