###
  00000000  00000000    0000000
  000       000   000  000     
  000000    00000000   0000000 
  000       000             000
  000       000        0000000 
###

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
        
        @colors = []
        for i in [0..32]
            red   = parseInt 32 + (255-32)*clamp 0,1, (i-16)/16
            green = parseInt 32 + (255-32)*clamp 0,1, (i-32)/32
            @colors.push "rgb(#{red}, #{green}, 32)"
        
        @history = []
        for i in [0...2*@width]
            @history[i] = 0
        @index = 0
        
        @last = window.performance.now()
            
        $("#main").appendChild @canvas
            
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: =>
        
        time = window.performance.now()
        @index += 1
        if @index > 2*@width
            @index = 0
        @history[@index] = time-@last
        @canvas.height = @canvas.height
        ctx = @canvas.getContext '2d'        
        for i in [0...@history.length]  
            ms = Math.max 0, @history[i]-17
            ctx.fillStyle = @colors[clamp 0, 32, parseInt ms]
            h = Math.min ms, 60
            ctx.fillRect (2*@width-@index+i)%(2*@width), 0, 2, h
        @last = time

module.exports = FPS

