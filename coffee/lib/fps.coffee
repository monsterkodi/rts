###
  00000000  00000000    0000000
  000       000   000  000     
  000000    00000000   0000000 
  000       000             000
  000       000        0000000 
###

{ elem, clamp, first, last, log, $}  = require 'kxk'

class FPS

    constructor: () ->
                    
        @width = 180
        @height = 60
        
        @canvas = elem 'canvas', 
            class:  'fps'
            height: 2*@height
            width:  2*@width

        y = parseInt -@height/2
        x = parseInt  @width/2
        @canvas.style.transform = "translate3d(#{x}px, #{y}px, 0px) scale3d(0.5, 0.5, 1)"
        
        @history = []
        @last = window.performance.now()
            
        $("#main").appendChild @canvas
            
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: =>
        
        time = window.performance.now()
        @history.push time-@last
        @history.shift() while @history.length > 2*@width
        @canvas.height = @canvas.height
        ctx = @canvas.getContext '2d'        
        for i in [0...@history.length]  
            ms = Math.max 0, @history[i]-17
            red = parseInt 32 + (255-32)*clamp 0,1, (ms-16)/16
            green = parseInt 32 + (255-32)*clamp 0,1, (ms-32)/32
            ctx.fillStyle = "rgb(#{red}, #{green}, 32)"
            h = Math.min ms, 60
            ctx.fillRect 2*@width-@history.length+i, 0, 2, h
        @last = time

module.exports = FPS

