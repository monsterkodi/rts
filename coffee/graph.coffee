###
 0000000   00000000    0000000   00000000   000   000
000        000   000  000   000  000   000  000   000
000  0000  0000000    000000000  00000000   000000000
000   000  000   000  000   000  000        000   000
 0000000   000   000  000   000  000        000   000
###

{ post, prefs, elem, log, $, _ } = require 'kxk'

{ Stone } = require './constants'

Color = require './color'

class Graph

    @graph = null
    @stones = []
    @stonesNum = 500 
    
    constructor: ->
        
        @width  = Graph.stonesNum*2
        @height = 100
        
        @canvas = elem 'canvas', 
            class:  "graph"
            height: 2*@height
            width:  2*@width

        y = parseInt -@height/2
        x = parseInt -@width/2
        @canvas.style.transform = "translate3d(#{x}px, #{y}px, 0px) scale3d(0.5, -0.5, 1)"
            
        $("#main").appendChild @canvas
        
        post.on 'tick', @draw
        
    del: -> 
        
        post.removeListener 'tick', @draw
        
        @canvas.remove()
            
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: =>
        @canvas.height = @canvas.height
        ctx = @canvas.getContext '2d'       
        for i in [0...Graph.stones.length]
            si = 0
            stones = Graph.stones[i].map (s) -> amount:s, stone:si++
            for s in [0...i]
                stones.push stones.shift()
            for stone in stones
                ctx.fillStyle = Color.cost[Stone.string stone.stone].getStyle()
                h = 196*stone.amount/state.storage.capacity
                ctx.fillRect i*4, h, 4, 4

    @toggle: -> 
        
        if @graph
            @graph.del()
            @graph = null
            prefs.set 'graph', false
        else
            prefs.set 'graph', true
            @graph = new Graph
            
    @sample: (v) ->
        
        @stones.push _.clone v
        @stones.shift() while @stones.length > @stonesNum

module.exports = Graph
