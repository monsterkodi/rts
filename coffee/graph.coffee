###
 0000000   00000000    0000000   00000000   000   000
000        000   000  000   000  000   000  000   000
000  0000  0000000    000000000  00000000   000000000
000   000  000   000  000   000  000        000   000
 0000000   000   000  000   000  000        000   000
###

class Graph

    @graph      = null
    @balance    = []
    @avgs       = [[],[],[],[]]
    @avgsNum    = 100
    @avgsSecs   = 10 
    
    constructor: ->
        
        @width     = 4*Graph.avgsNum*2
        @height    = 100
        @size      = vec @width*window.devicePixelRatio, @height*window.devicePixelRatio
        
        @canvas = elem 'canvas', 
            class:  "graph"
            width:  @size.x
            height: @size.y

        y = parseInt -@height/2
        x = parseInt -@width/2
        @canvas.style.transform = "translate3d(#{x}px, #{y}px, 0px) scale3d(#{1/window.devicePixelRatio}, -#{1/window.devicePixelRatio}, 1)"
            
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
        
        stoneStyles = Stone.resources.map (s) -> Color.stone[Stone.string s].getStyle()
        spentStyles = Stone.resources.map (s) -> Color.spent[Stone.string s].getStyle()

        for stone in Stone.resources     
            avgs = Graph.avgs[stone]

            for i in [0...avgs.length]
                [gain, spent] = avgs[i]
                h = gain*2
                ctx.fillStyle = stoneStyles[stone]
                ctx.fillRect i*4+Graph.avgsNum*stone*4, 98, 2, h
                h = -spent*2
                ctx.fillStyle = spentStyles[stone]
                ctx.fillRect i*4+Graph.avgsNum*stone*4, 98, 2, h
                
    @toggle: -> 
        
        if @graph
            @graph.del()
            @graph = null
            # prefs.set 'graph', false
        else
            # prefs.set 'graph', true
            @graph = new Graph
            
    @sampleStorage: (storage) ->
        
        @balance.push _.clone storage.balance
        @balance.shift() while @balance.length > @avgsSecs

        storage.resetBalance()
        
        for stone in Stone.resources
            avg = [0,0]
            if lst = last @avgs[stone]
                avg[0] = lst[0]
                avg[1] = lst[1]
            avg[0] += last(@balance).gains[stone] 
            avg[1] += last(@balance).spent[stone]
            if @balance.length >= @avgsSecs
                avg[0] -= @balance[0].gains[stone] 
                avg[1] -= @balance[0].spent[stone]
            @avgs[stone].push avg
            @avgs[stone].shift() while @avgs[stone].length > @avgsNum
                
module.exports = Graph
