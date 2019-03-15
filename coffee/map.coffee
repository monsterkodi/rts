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
        
    # 00     00  00000000  000000000   0000000   
    # 000   000  000          000     000   000  
    # 000000000  0000000      000     000000000  
    # 000 0 000  000          000     000   000  
    # 000   000  00000000     000     000   000  
    
    meta: ->

        @isMeta = true
        
        s = 6
        @wall -s, 0, 0, s, 0, 0
        @wall 0, -s, 0, 0, s, 0
        
        @addBot   0, 0, 1, Bot.base
        # @addIcon  0, 6, 1, 'grid'
        # @addIcon  0, 3, 1, 'star'
        # @addIcon  6, 0, 1, 'simple'
        @addIcon  0, 2, 1, 'ai1'
        @addIcon  0, 4, 1, 'ai2'
        @addIcon  0, 6, 1, 'ai3'
        @addIcon  4, 0, 1, 'pest'
        @addIcon  0,-4, 1, 'sparse'
        @addIcon -4, 0, 1, 'plenty'
        
        # @addResource  3, 0,0, Stone.blue 
        # @addResource -3, 0,0, Stone.blue 
        
        @setCamera dist:10, rotate:45, degree:45
        
        science().path.length = 16
        science().base.speed  = Number.EPSILON
      
    #  0000000  000  00     00  00000000   000      00000000  
    # 000       000  000   000  000   000  000      000       
    # 0000000   000  000000000  00000000   000      0000000   
    #      000  000  000 0 000  000        000      000       
    # 0000000   000  000   000  000        0000000  00000000  
    
    simple: ->
        
        @addStone 0,0,0
        @addStone 1,0,0
        @addStone -1,0,0
        @addStone 0,-1,0
        @addStone 0,1,0
        @addBot 0,0,1, Bot.base
        
        @setCamera()
        
    #  0000000  000000000   0000000   00000000   
    # 000          000     000   000  000   000  
    # 0000000      000     000000000  0000000    
    #      000     000     000   000  000   000  
    # 0000000      000     000   000  000   000  
    
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
        @setCamera()

    #  0000000   000     000  
    # 000   000  000   00000  
    # 000000000  000  000000  
    # 000   000  000     000  
    # 000   000  000     000  
    
    ai1: ->
                
        h = 4
        r = 4
        d = 3
        
        for x in [-r..r]
            for y in [-r..r]
                for z in [0...h]
                    maxAbs = Math.max Math.abs(x), Math.abs(y)
                    res = 16+(r-(maxAbs))*64
                    @addStone x*d, y*d, -z-maxAbs*4+r*4, Stone.resources[z], res
        
        @addBot 0, r*d, 1, Bot.base
        @addBot 0,-r*d, 1, Bot.base
        
        @setCamera dist:20, rotate:180, degree:70
        
    #  0000000   000  00000   
    # 000   000  000     000  
    # 000000000  000    000   
    # 000   000  000   000    
    # 000   000  000  000000  
    
    ai2: ->
                
        h = 4
        r = 4
        d = 3
        
        for x in [-r..r]
            for y in [-r..r]
                for z in [0...h]
                    maxAbs = Math.max Math.abs(x), Math.abs(y)
                    res = 16+(r-(maxAbs))*64
                    @addStone x*d, y*d, -z-maxAbs*4+r*4, Stone.resources[z], res
        
        @addBot  0, r*d, 1, Bot.base
        @addBot  r*d, 0, 1, Bot.base
        @addBot -r*d, 0, 1, Bot.base
        
        @setCamera dist:20, rotate:180, degree:70
        
    #  0000000   000  000000   
    # 000   000  000      000  
    # 000000000  000    0000   
    # 000   000  000      000  
    # 000   000  000  000000   
    
    ai3: ->
        
        @wall  0,-3,0, 0, 3,0
        @wall -3, 0,0, 3, 0,0
        
        @wall -3, 5,0, 3, 5,0
        @wall -3,-5,0, 3,-5,0
        @wall  5,-3,0, 5, 3,0
        @wall -5,-3,0,-5, 3,0

        @wall -1, 3,4, 1, 3,4
        @wall -1,-3,4, 1,-3,4
        @wall  3,-1,4, 3, 1,4
        @wall -3,-1,4,-3, 1,4
        
        res = 80
                
        @addResource -2, -5, 0, Stone.white, res
        @addResource -1, -5, 0, Stone.red,   res
        @addResource  1, -5, 0, Stone.gelb,  res
        @addResource  2, -5, 0, Stone.blue,  res

        @addResource -1, -3, 4, Stone.white, res
        @addResource  1, -3, 4, Stone.white, res
        
        @addResource -2,  5, 0, Stone.white, res
        @addResource -1,  5, 0, Stone.red,   res
        @addResource  1,  5, 0, Stone.gelb,  res
        @addResource  2,  5, 0, Stone.blue,  res

        @addResource -1,  3, 4, Stone.white, res
        @addResource  1,  3, 4, Stone.white, res
        
        @addResource  5, -2, 0, Stone.white, res
        @addResource  5, -1, 0, Stone.red,   res
        @addResource  5,  1, 0, Stone.gelb,  res
        @addResource  5,  2, 0, Stone.blue,  res

        @addResource  3, -1, 4, Stone.white, res
        @addResource  3,  1, 4, Stone.white, res
        
        @addResource -5, -2, 0, Stone.white, res
        @addResource -5, -1, 0, Stone.red,   res
        @addResource -5,  1, 0, Stone.gelb,  res
        @addResource -5,  2, 0, Stone.blue,  res

        @addResource -3, -1, 4, Stone.white, res
        @addResource -3,  1, 4, Stone.white, res

        @addBot  0,-5, 1, Bot.base
        @addBot -5, 0, 1, Bot.base
        @addBot  0, 5, 1, Bot.base
        @addBot  5, 0, 1, Bot.base
        
        @addCancer  0,  0, 8, 25
        @addCancer  3,  3, 0, 15
        @addCancer -3, -3, 0, 15
        @addCancer -3,  3, 0, 15
        @addCancer  3, -3, 0, 15
        
        @setCamera dist:12, rotate:45, degree:70, pos:[0,0,0]
        
    # 00000000   00000000   0000000  000000000  
    # 000   000  000       000          000     
    # 00000000   0000000   0000000      000     
    # 000        000            000     000     
    # 000        00000000  0000000      000     
    
    pest: ->

        @addCancer 0,  0,  10, 15
        @addCancer 0,  0, -10,  5
        @addCancer 0,  10,  0, 10
        @addCancer 0, -10,  0, 10
        @addCancer 0,   0,  0,  3
        
        @wall 0,1,0, 0,3,0
        @wall 0,-1,0, 0,-3,0

        @addStone -3, 0, 0, Stone.blue,  256
        @addStone -2, 0, 0, Stone.red,   128
        @addStone -1, 0, 0, Stone.white, 32
        @addStone  1, 0, 0, Stone.white, 32
        @addStone  2, 0, 0, Stone.gelb,  128
        @addStone  3, 0, 0, Stone.blue,  256
        
        @addStone 0, 0, 4, Stone.white, 80
        @addBot  0, 0, 5, Bot.base
        
        @addTarget  10, 0, 0
        @addTarget -10, 0, 0
        
        @setCamera rotate:0, degree:70, dist:20, pos:[0,0,0]
        
    #  0000000   00000000   000  0000000    
    # 000        000   000  000  000   000  
    # 000  0000  0000000    000  000   000  
    # 000   000  000   000  000  000   000  
    #  0000000   000   000  000  0000000    
    
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
        
        @setCamera()
          
    #  0000000  00000000    0000000   00000000    0000000  00000000  
    # 000       000   000  000   000  000   000  000       000       
    # 0000000   00000000   000000000  0000000    0000000   0000000   
    #      000  000        000   000  000   000       000  000       
    # 0000000   000        000   000  000   000  0000000   00000000  
    
    sparse: ->
        
        @addStone  0, 0,  0
        
        @addStone  1, 0, 0, Stone.red,   240
        @addStone -1, 0, 0, Stone.gelb,  240
        @addStone  0,-1, 0, Stone.white, 240
        @addStone  0, 1, 0, Stone.blue,  240
        
        s = 4
        @addStone  s,  s, 0, Stone.red
        @addStone -s,  s, 0, Stone.gelb
        @addStone -s, -s, 0, Stone.blue

        s = 10
        @addStone  0, 0, -s, Stone.white
        
        s = 6
        @addTarget s,s,s
        @addTarget -s,s,s
        @addTarget -s,-s,s

        @addTarget s,s,-s
        @addTarget -s,-s,-s
        @addTarget s,-s,-s
        
        @addBot  0, 0, 1, Bot.base
        @setCamera dist:20
        
    # 00000000   000      00000000  000   000  000000000  000   000  
    # 000   000  000      000       0000  000     000      000 000   
    # 00000000   000      0000000   000 0 000     000       00000    
    # 000        000      000       000  0000     000        000     
    # 000        0000000  00000000  000   000     000        000     
    
    plenty: ->
           
        a = 32
        @addStone  0, 0, 0
        @addStone  1, 0, 0, Stone.white, a
        @addStone  0, 1, 0, Stone.gelb, a
        @addStone -1, 0, 0, Stone.red, a
        @addStone  0,-1, 0, Stone.blue, a

        a = 64
        @addStone  2, 0, -2, Stone.gelb, a
        @addStone  0, 2, -2, Stone.red, a
        @addStone -2, 0, -2, Stone.blue, a
        @addStone  0,-2, -2, Stone.white, a

        a = 128
        @addStone  3, 0, -4, Stone.red, a
        @addStone  0, 3, -4, Stone.blue, a
        @addStone -3, 0, -4, Stone.white, a
        @addStone  0,-3, -4, Stone.gelb, a

        # @addStone  4, 0, -6, Stone.blue
        # @addStone  0, 4, -6, Stone.white
        # @addStone -4, 0, -6, Stone.gelb
        # @addStone  0,-4, -6, Stone.red
         
        @addStone  0,0,-8, Stone.red
        
        @wall  0, 0,-2, 0,0,-3
        @wall -1,-1,-2, 1,1,-2
        
        @addBot  0, 0, 1, Bot.base
        # @addBot  1, 1, -2, Bot.base
        
        r = 4
        h = 5
        @addTarget  0, 0, 2
        @addTarget  r, 0, h
        @addTarget -r, 0, h
        @addTarget  0, r, h
        @addTarget  0,-r, h
        @setCamera degree:88, dist:16
        
module.exports = Map
