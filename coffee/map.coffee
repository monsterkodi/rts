###
00     00   0000000   00000000 
000   000  000   000  000   000
000000000  000000000  00000000 
000 0 000  000   000  000      
000   000  000   000  000      
###

{ randInt, log, _ } = require 'kxk'

{ Stone, Bot, Face } = require './constants'

Config = require './config'
World  = require './world'

class Map extends World

    constructor: (scene) ->
        
        super scene, Config.default
        
    build: ->
        
        @pest()
        # @grid()
        # @sparse()
        # @plenty()
        
    pest: ->

        d = 3
        @addMonster  d, d, -d
        @addMonster  d,-d, -d
        @addMonster -d, d, -d
        @addMonster -d,-d, -d
        
        @addMonster  d, d,  d
        @addMonster  d,-d,  d
        @addMonster -d, d,  d
        @addMonster -d,-d,  d
        
        s = 32
        for i in [0..200]
            @addMonster randInt(s)-s/2, randInt(s)-s/2, randInt(s)-s/2

        @addStone  0, 0, 0
        @addStone  1, 0, 0
        @addStone  2, 0, 0
        @addStone  3, 0, 0
        @addStone -2, 0, 0
        @addStone -3, 0, 0
        
        @addResource 0, 0, 0, Stone.red,   32
        @addResource 1, 0, 0, Stone.gelb,  64
        @addResource 2, 0, 0, Stone.blue,  128
        @addResource 3, 0, 0, Stone.white, 256
        
        @addBot  0, 0, 1, Bot.base
        
    grid: ->
        
        @addStone  0, 0,-1
        @addStone  3, 0, 0
        @addStone -2, 0, 0
        @addStone -3, 0, 0
        @addStone  2, 0, 0
                
        for z in [0..0]
            for y in [-5..5]
                @wall -20,y*4,z*2, 20,y*4,z*2
                @wall y*4,-20,z*2, y*4,20,z*2

        for x in [-2..2]
            for y in [-2..2]
                 
                @addStone  x*8-1, y*8,   0, Stone.red
                @addStone  x*8,   y*8-1, 0, Stone.gelb
                @addStone  x*8,   y*8+1, 0, Stone.white
                @addStone  x*8+1, y*8,   0, Stone.blue
                @addStone  0,       2,   0, Stone.white
                @addStone  0,      -2,   0, Stone.white
                
        @addBot  0, 0, 1, Bot.base
          
    sparse: ->
        
        @addStone  0, 0,  0
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
        
module.exports = Map
