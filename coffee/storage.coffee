###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ post, clamp, menu, log, _ } = require 'kxk'

{ Stone } = require './constants'

CanvasButton = require './menu/canvasbutton'
Materials    = require './materials'
Graph        = require './graph'
Color        = require './color'
Boxes        = require './boxes'

class Storage extends CanvasButton

    constructor: (menu) ->
        
        @dirty     = false
        @stones    = [0,0,0,0]
        @temp      = [0,0,0,0]
        @box       = [[],[],[],[]]

        @resetBalance()
        
        super menu.div
        
        @boxes = new Boxes @scene, 4*320, new THREE.BoxBufferGeometry
        @name  = 'Storage'
        
        for stone in Stone.resources
            @add stone, state.storage.stones[stone], 'init'
            
        post.on 'scienceFinished', @onScienceFinished
            
        @render()
        
    onScienceFinished: (scienceKey) =>
        
        if scienceKey == 'storage.capacity'
            log state.storage
            stones = _.clone @stones
            @deduct @stones, 'reset'
            for stone in Stone.resources
                @add stone, stones[stone], 'reset'
                
            @render()
        
    resetBalance: -> @balance = gains:[0,0,0,0], spent:[0,0,0,0]
        
    capacity: -> state.science.storage.capacity
        
    click: -> Graph.toggle()
    
    animate: (delta) ->
        
        if @dirty
            @render()
            post.emit 'storageChanged'
            @dirty = false
               
    has: (stone, amount) -> @stones[stone] >= amount
            
    canTake: (stone, amount=1) -> 
        
        return 0 if stone == Stone.gray
        clamp 0, amount, @capacity() - @stones[stone] - @temp[stone]

    willSend: (stone) -> @temp[stone] += 1
        
    deductBuild: -> 
        
        if @canAfford state.science.build.cost
            @deduct state.science.build.cost
            @dirty = true
            return true
        false
        
    canAfford: (cost) ->
        
        for stone in Stone.resources
            if @stones[stone] < cost[stone]
                return false
        true
                
    clear: -> @deduct @stones, 'clear'
    fill:  -> @deduct [-@capacity(), -@capacity(), -@capacity(), -@capacity()], 'fill'

    deduct: (cost, reason) ->
        
        for stone in Stone.resources
            @add stone, -cost[stone], reason
    
    posForStone: (stone, i) ->
        
        cap = @capacity()
        if false # cap == 80
            pos = vec stone*1.5-2.5, 0, 0
            pos.y = 1.2*Math.floor (i-1)/8
            pos.y += @stoneSize if (i-1)%8 > 3
            pos.x += @stoneSize if (i-1)%4 in [1,2]
            pos.z += @stoneSize if (i-1)%4 in [2,3]
        else 
            pos = vec stone*1.6-2.7, 0, 0
            l = cap/10
            h = l/2
            pos.y = 1.2*Math.floor (i-1)/l
            pos.y += @stoneSize if (i-1)%l > h-1
            pos.x += @stoneSize if (i-1)%2 == 1
            pos.z += @stoneSize * Math.floor ((i-1)%h)/2 
        pos
            
    add: (stone, amount=1, reason=null) ->
        
        oldStones = @stones[stone]
        
        @stones[stone] += amount
        @stones[stone] = clamp 0, @capacity(), @stones[stone]
        
        if not reason
            delta = @stones[stone]-oldStones
            if delta > 0
                @balance.gains[stone] += delta
            else 
                @balance.spent[stone] -= delta

        while @box[stone].length < @stones[stone]
            @box[stone].push @boxes.add stone:stone, size:@stoneSize, pos:@posForStone stone, @box[stone].length+1

        while @box[stone].length > @stones[stone]
            @boxes.del @box[stone].pop()
                
        @dirty = true
    
    #  0000000   0000000  00000000  000   000  00000000  
    # 000       000       000       0000  000  000       
    # 0000000   000       0000000   000 0 000  0000000   
    #      000  000       000       000  0000  000       
    # 0000000    0000000  00000000  000   000  00000000  
    
    initScene: ->
                
        @scene.background = Color.menu.background
        
        @light = new THREE.DirectionalLight 0xffffff
        @light.position.set 0,10,6
        @scene.add @light
        
        @scene.add new THREE.AmbientLight 0xffffff
        
        @camera.fov = 40
        @camera.position.copy vec(0,2,1).normal().mul 22
            
    highlight: -> 

        @camera.fov = 36
        @render()
    
    unhighlight: ->

        @camera.fov = 40
        @render()
        
    # 00000000   00000000  000   000  0000000    00000000  00000000   
    # 000   000  000       0000  000  000   000  000       000   000  
    # 0000000    0000000   000 0 000  000   000  0000000   0000000    
    # 000   000  000       000  0000  000   000  000       000   000  
    # 000   000  00000000  000   000  0000000    00000000  000   000  
    
    render: ->

        switch @capacity()
            when 320 then @camera.lookAt vec 0, 5.6, 0
            when 240 then @camera.lookAt vec 0, 6.0, 0
            when 200 then @camera.lookAt vec 0, 6.4, 0
            when 160 then @camera.lookAt vec 0, 6.8, 0
            when 120 then @camera.lookAt vec 0, 7.2, 0
            when  80 then @camera.lookAt vec 0, 7.6, 0
                
        @camera.updateProjectionMatrix()
        
        @boxes.render()
        super()
            
module.exports = Storage
