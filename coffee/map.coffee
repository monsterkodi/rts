###
00     00   0000000   00000000 
000   000  000   000  000   000
000000000  000000000  00000000 
000 0 000  000   000  000      
000   000  000   000  000      
###

{ log, _ } = require 'kxk'

{ Stone, Bot, Face } = require './constants'

Config = require './config'
World  = require './world'

class Map extends World

    constructor: (scene) ->
        
        super scene, Config.default
        
    build: ->

        # @addStone  0, 0,-1
        # @addStone  3, 0, 0
        # @addStone -2, 0, 0
        # @addStone -3, 0, 0
        # @addStone  2, 0, 0
                
        # for z in [0..0]
            # for y in [-5..5]
                # @wall -20,y*4,z*2, 20,y*4,z*2
                # @wall y*4,-20,z*2, y*4,20,z*2

        # for x in [-2..2]
            # for y in [-2..2]
#                 
                # @addStone  x*8-1, y*8,   0, Stone.red
                # @addStone  x*8,   y*8-1, 0, Stone.gelb
                # @addStone  x*8,   y*8+1, 0, Stone.white
                # @addStone  x*8+1, y*8,   0, Stone.blue
                # @addStone  0, 2, 0, Stone.white
                # @addStone  0,-2, 0, Stone.white
                
        @addStone  0,0,0 #, Stone.white
        @addStone  0,0,-1, Stone.white
        
        @addBot  0, 0, 1, Bot.base
        # @addBot  0, 0, 1, Bot.trade
        # @addBot  0, 2, 1, Bot.mine
        
module.exports = Map
