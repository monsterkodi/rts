###
00     00   0000000   00000000 
000   000  000   000  000   000
000000000  000000000  00000000 
000 0 000  000   000  000      
000   000  000   000  000      
###

{ log, _ } = require 'kxk'

{ Stone, Bot, Face } = require './constants'

World = require './world'

class Map extends World

    constructor: (scene) ->
        
        super scene
        
    build: ->

        @addStone  0, 0,-1
        @addStone  3, 0, 0
        @addStone -2, 0, 0
        @addStone -3, 0, 0
        @addStone  2, 0, 0
                
        @addStone  1, 0, 0, Stone.red
        @addStone  0, 1, 0, Stone.green
        @addStone  0, 0, 1, Stone.blue
        @addStone -1, 0, 0, Stone.yellow
        @addStone -2, 0, 0, Stone.white
        @addStone -3, 0, 0, Stone.blue
        
        @base = @addBot 0, 0, 0, Bot.dodicos, Face.PX

        @addBot -2, 0, 1, Bot.octacube
        @addBot  0, 1, 1, Bot.tubecross
        @addBot  0, 0, 2, Bot.toruscone
        @addBot  -2, 0, -1, Bot.knot, Face.NZ
        
module.exports = Map
