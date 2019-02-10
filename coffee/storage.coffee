###
 0000000  000000000   0000000   00000000    0000000    0000000   00000000
000          000     000   000  000   000  000   000  000        000     
0000000      000     000   000  0000000    000000000  000  0000  0000000 
     000     000     000   000  000   000  000   000  000   000  000     
0000000      000      0000000   000   000  000   000   0000000   00000000
###

{ elem, log, _ } = require 'kxk'

{ Stone } = require './constants'

class Storage

    constructor: (@world) ->
        
        @stones    = [0,0,0,0,1000]
        @temp      = [0,0,0,0,0]
        @maxStones = 1000
        @bgcol     = "rgba(25,25,25)"
        
        @elem = elem class:'storage'

        @canvas = elem 'canvas', 
            class: "storageCanvas"
            height: 100
            width:  100
            
        @elem.appendChild @canvas

        t = "translate3d(0px, 0px, 0px) scale3d(1, -1, 1)"
        @canvas.style.transform = t
        
        document.body.appendChild @elem
                
    canTake: (stone) -> 
        
        return false if stone == Stone.gray
        if @stones[stone] + @temp[stone] < @maxStones
            @temp[stone] += 1
            return true
        false
        
    canBuild: -> 
        log 'white', @stones[Stone.white]
        if @stones[Stone.white] >= 100
            @stones[Stone.white] -= 100
            log 'deduct 100'
            @render()
            return true
        false
        
    add: (stone) ->
        
        @stones[stone] += 1
        @render()
    
    render: ->
        
        x = 0
        ctx = @canvas.getContext '2d'        
        
        ctx.fillStyle = @bgcol
        ctx.fillRect 0,0,100,100
        
        for s in Stone.resources
            ctx.fillStyle = switch s
                    when Stone.red    then "rgb(155, 0, 0)"
                    when Stone.gelb   then "rgb(255, 155, 0)"
                    when Stone.blue   then "rgb(0, 0, 230)"
                    when Stone.white  then "rgb(155, 155, 255)"
            ctx.fillRect x+5,0,15,@stones[s]/10
            x += 25
            
        for y in [0..10]
            ctx.fillStyle = @bgcol
            ctx.fillRect 0,y*10,100,1
        
module.exports = Storage
