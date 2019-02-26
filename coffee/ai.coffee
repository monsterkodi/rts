###
 0000000   000
000   000  000
000000000  000
000   000  000
000   000  000
###

{ log, _ } = require 'kxk'

{ Bot, Stone } = require './constants'

class AI

    constructor: (@world, @base) ->
        
        @player = @base.player
        
    animate: (scaledDelta) -> 
    
        for bot in [Bot.mine, Bot.trade, Bot.brain, Bot.build]
            if not @world.botOfType bot, @player
                rts.handle.buyBot bot, @player
                return 
                            
module.exports = AI
