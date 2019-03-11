###
00     00   0000000   00000000 
000   000  000   000  000   000
000000000  000000000  00000000 
000 0 000  000   000  000      
000   000  000   000  000      
###

World  = require './world'

class Map extends World

    constructor: (scene) ->
        
        super scene
        
    build: -> @meta()
        
    meta: ->

        @isMeta = true
        
        s = 6
        @wall -s, 0, 0, s, 0, 0
        @wall 0, -s, 0, 0, s, 0
        
        @addBot   0, 0, 1, Bot.base
        @addIcon  0, 6, 1, 'grid'
        @addIcon  0, 3, 1, 'star'
        @addIcon  6, 0, 1, 'simple'
        @addIcon -3, 0, 1, 'ais'
        @addIcon  3, 0, 1, 'pest'
        @addIcon -6, 0, 1, 'plenty'
        @addIcon  0,-6, 1, 'sparse'
        
        # @addResource  3, 0,0, Stone.blue 
        # @addResource -3, 0,0, Stone.blue 
        
        science(0).path.length = 16
      
    simple: ->
        
        @addStone 0,0,0
        @addStone 1,0,0
        @addStone -1,0,0
        @addStone 0,-1,0
        @addStone 0,1,0
        @addBot 0,0,1, Bot.base
        
    star: ->
        
        for n in Vector.normals
            c = vec()
            o = n.mul 64
            @wall c.x, c.y, c.z, c.x+o.x, c.y+o.y, c.z+o.z
            c = o.mul 0.5
            for n in Vector.normals
                o = n.mul 32
                @wall c.x, c.y, c.z, c.x+o.x, c.y+o.y, c.z+o.z
                d = c.plus o.mul 0.5
                for n in Vector.normals
                    o = n.mul 16
                    @wall d.x, d.y, d.z, d.x+o.x, d.y+o.y, d.z+o.z 
            
        @addBot  5, 0, 1, Bot.base
        # @addBot -5, 0, 1, Bot.base
        
    ais: ->
        
        @wall  0,-3,0, 0, 3,0
        @wall -3, 0,0, 3, 0,0
        
        @wall -3, 5,0, 3, 5,0
        @wall -3,-5,0, 3,-5,0
        @wall  5,-3,0, 5, 3,0
        @wall -5,-3,0,-5, 3,0

        @wall  0, 5,3, 0, 5,6
        @wall  0,-5,5, 0,-5,8
        @wall  5,-2,3, 5, 2,3
        @wall -5,-2,3,-5, 2,3
        
        res = 80
                
        @addResource -3, -5, 0, Stone.white, res
        @addResource -2, -5, 0, Stone.red,   res
        @addResource -1, -5, 0, Stone.gelb,  res
        @addResource  0, -5, 0, Stone.blue,  res

        @addResource  3,  5, 0, Stone.white, res
        @addResource  2,  5, 0, Stone.red,   res
        @addResource  1,  5, 0, Stone.gelb,  res
        @addResource  0,  5, 0, Stone.blue,  res

        @addResource  5, -2, 0, Stone.white, res
        @addResource  5, -1, 0, Stone.red,   res
        @addResource  5,  1, 0, Stone.gelb,  res
        @addResource  5,  2, 0, Stone.blue,  res
                          
        @addResource -5, -3, 0, Stone.white, res
        @addResource -5, -2, 0, Stone.red,   res
        @addResource -5,  2, 0, Stone.gelb,  res
        @addResource -5,  3, 0, Stone.blue,  res

        @addResource -5, -2, 3, Stone.white, res
        @addResource -5,  2, 3, Stone.white, res
        
        @addResource  0,  5, 5, Stone.white, res
        @addResource  0, -5, 5, Stone.white, res

        @addResource  5, -1, 3, Stone.white, res
        @addResource  5, -2, 3, Stone.white, res
        @addResource  5,  2, 3, Stone.white, res
        @addResource  5,  1, 3, Stone.white, res

        @addBot  0,-5, 1, Bot.base
        @addBot -5, 0, 1, Bot.base
        @addBot  0, 5, 1, Bot.base
        @addBot  5, 0, 1, Bot.base
        
        @addCancer  0,  0, 10, 25
        @addCancer  3,  3,  0, 15
        @addCancer -3, -3,  0, 15
        @addCancer -3,  3,  0, 15
        @addCancer  3, -3,  0, 15
        
    pest: ->

        @addCancer 0,  0,  10, 15
        @addCancer 0,  0, -10,  5
        @addCancer 0,  10,  0, 10
        @addCancer 0, -10,  0, 10
        @addCancer 0,   0, -1,  3
        
        @wall 0,-3,0, 0,3,0
        @wall -3,0,0, 3,0,0
        @addResource -3, 0, 0, Stone.white, 256
        @addResource -2, 0, 0, Stone.red,   128
        @addResource -1, 0, 0, Stone.gelb,  64
        @addResource  0, 0, 0, Stone.blue,  32
        @addResource  1, 0, 0, Stone.gelb,  64
        @addResource  2, 0, 0, Stone.red,   128
        @addResource  3, 0, 0, Stone.white, 256
        
        @addBot  0, 0, 1, Bot.base
        
    grid: ->
        
        @addStone  0, 0,-1
        @addStone  3, 0, 0
        @addStone -2, 0, 0
        @addStone -3, 0, 0
        @addStone  2, 0, 0
                
        for z in [0, -127]
            for y in [-5..5]
                @wall -20,y*4,z, 20,y*4,z
                @wall y*4,-20,z, y*4,20,z

        for x in [-2..2]
            for y in [-2..2]
                for z in [0..0] by 2
                 
                    @addStone  x*8-1, y*8,   z, Stone.red
                    @addStone  x*8,   y*8-1, z, Stone.gelb
                    @addStone  x*8,   y*8+1, z, Stone.white
                    @addStone  x*8+1, y*8,   z, Stone.blue
                    @addStone  0,       2,   z, Stone.white
             
        for x in [-20..20] by 8
            for y in [-20..20] by 8
                @wall x, y, 0, x, y, -127
                
        @addBot  0, 0, 1, Bot.base
          
    sparse: ->
        
        @addStone  0, 0,  0
        
        @addStone  1, 0, 0, Stone.red,   240
        @addStone -1, 0, 0, Stone.gelb,  240
        @addStone  0,-1, 0, Stone.white, 240
        @addStone  0, 1, 0, Stone.blue,  240
        
        @addStone  8, 8,  0, Stone.red
        @addStone  8, -8, 0, Stone.gelb
        @addStone -8,  8, 0, Stone.white
        @addStone -8, -8, 0, Stone.blue
        
        @addBot  0, 0, 1, Bot.base
        
    plenty: ->
                
        @addStone  0, 0, 0
        @addStone  1, 0, 0, Stone.white
        @addStone  0, 1, 0, Stone.gelb
        @addStone -1, 0, 0, Stone.red
        @addStone  0,-1, 0, Stone.blue

        @addStone  2, 0, -2, Stone.gelb
        @addStone  0, 2, -2, Stone.red
        @addStone -2, 0, -2, Stone.blue
        @addStone  0,-2, -2, Stone.white

        @addStone  3, 0, -4, Stone.red
        @addStone  0, 3, -4, Stone.blue
        @addStone -3, 0, -4, Stone.white
        @addStone  0,-3, -4, Stone.gelb

        @addStone  4, 0, -6, Stone.blue
        @addStone  0, 4, -6, Stone.white
        @addStone -4, 0, -6, Stone.gelb
        @addStone  0,-4, -6, Stone.red
         
        @wall  0, 0,-1, 0,0,-3
        @wall -1,-1,-2, 1,1,-2
        
        @addBot  0, 0, 1, Bot.base
        # @addBot  1, 1, -2, Bot.base
        
module.exports = Map
