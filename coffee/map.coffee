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

        # @wall -2, 0, 0, 2, 0, 0
        # @wall 0, -2, 0, 0, 2, 0
        @addStone 0,0,-1
        # @addStone -1, 1,0
        # @addStone  1,-1,0
        # @addStone  1, 1,0
        # @delStone 0, 0, 0
                
        @cube = @addBot  0,0,0, Bot.dodicos#, Face.NX
        @addStone -1, 0,0, Stone.yellow
        @addStone  0,-1,0, Stone.blue
        @addStone  0, 1,0, Stone.red
        @addStone  1, 0,0, Stone.green

        @addBot -1, 0,1,  Bot.octacube
        @addBot  0, 1,1,  Bot.tubecross
        @addBot  0,-1,1,  Bot.toruscone
        @addBot  1, 0,1,  Bot.knot
        
module.exports = Map
