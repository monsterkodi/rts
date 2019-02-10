###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000     
000000000  000000000  000 0 000  000   000  000      0000000 
000   000  000   000  000  0000  000   000  000      000     
000   000  000   000  000   000  0000000    0000000  00000000
###

{ log, _ } = require 'kxk'

{ Bot } = require './constants'

Vector = require './lib/vector'

class Handle

    constructor: (@world) ->
        
    botClicked: (bot) -> 
    
        # log 'botClicked', rts.mouse
        hit = rts.castRay()
        # log 'hit', @world.stringForBot(hit.bot?.type), hit.norm
        
        switch hit.bot?.type 
            when Bot.build then @buildBotHit bot, hit

    buildBotHit: (bot, hit) ->
        
        for n in Vector.normals
            if hit.norm.equals n
                if @world.storage.canBuild()
                    log 'build', n
                    @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
                    @world.moveBot bot, bot.pos.plus n
                    @world.construct.stones()
                else
                    log 'cant build'
                return        
            else
                log hit.norm.manhattan n
            
module.exports = Handle
