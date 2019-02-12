###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000     
000000000  000000000  000 0 000  000   000  000      0000000 
000   000  000   000  000  0000  000   000  000      000     
000   000  000   000  000   000  0000000    0000000  00000000
###

{ log, _ } = require 'kxk'

{ Face, Bot } = require './constants'

Vector = require './lib/vector'

class Handle

    constructor: (@world) ->
        
    botClicked: (bot) -> 
    
        hit = rts.castRay()
        
        switch hit?.bot?.type 
            when Bot.build then @buildBotHit bot, hit

    buildBotHit: (bot, hit) ->
        
        normal = hit.norm.applyQuaternion bot.mesh.quaternion
        hitpos = bot.pos.to hit.point

        n = Vector.closestNormal hitpos
        newFace = Vector.normals.indexOf n
        newPos = bot.pos.plus n
        if @world.stoneAtPos(newPos)?
            log 'occupied negate'
            n.negate()
            newFace = (newFace+3) % 6
            newPos = bot.pos.plus n
            
        if @world.stoneAtPos(newPos)? or @world.botAtPos(newPos)?
            log 'target occupied'
            return
        
        if @world.storage.canBuild()
            log newPos, Face.toString newFace
            rts.camera.focusOnPos rts.camera.center.plus n
            @world.addStone bot.pos.x, bot.pos.y, bot.pos.z
            @world.moveBot bot, newPos, newFace
            @world.construct.stones()
        else
            log 'cant build'

    moveBot: (bot, pos, face) ->
        
        wbot = @world.botAtPos(pos)
        if not wbot or wbot == bot
            index = @world.indexAtPos pos
            if bot.face != face or bot.index != index
                @world.moveBot bot, pos, face
                @world.highlightPos bot.pos
            
module.exports = Handle
