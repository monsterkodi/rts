###
000   000   0000000   000   000  0000000    000      00000000
000   000  000   000  0000  000  000   000  000      000
000000000  000000000  000 0 000  000   000  000      0000000
000   000  000   000  000  0000  000   000  000      000
000   000  000   000  000   000  0000000    0000000  00000000
###

class Handle

    constructor: ->

    doubleClick: ->
        
        @placeBase()

    # 0000000    00000000  000       0000000   000   000
    # 000   000  000       000      000   000   000 000
    # 000   000  0000000   000      000000000    00000
    # 000   000  000       000      000   000     000
    # 0000000    00000000  0000000  000   000     000

    delay: (delta, bot, speed, delay, func) ->

        bot[delay] -= delta
        if bot[delay] <= 0
            if func bot
                bot[delay] += 1/2
            else
                bot[delay] = 0

    # 000000000  000   0000000  000   000
    #    000     000  000       000  000
    #    000     000  000       0000000
    #    000     000  000       000  000
    #    000     000   0000000  000   000

    tickBot: (delta, bot) ->

        switch bot.type
            when Bot.base  then @tickBase  delta, bot

    # 0000000     0000000    0000000  00000000
    # 000   000  000   000  000       000
    # 0000000    000000000  0000000   0000000
    # 000   000  000   000       000  000
    # 0000000    000   000  0000000   00000000

    tickBase: (delta, base) ->
        
    placeBase: ->
        
        if hit = rts.castRay true
            if not hit.bot
                @moveBot world.bases[0], hit.pos, hit.face
                
    # 00     00   0000000   000   000  00000000
    # 000   000  000   000  000   000  000
    # 000000000  000   000   000 000   0000000
    # 000 0 000  000   000     000     000
    # 000   000   0000000       0      00000000

    moveBotToFaceIndex: (bot, faceIndex) ->
        
        [face, index] = world.splitFaceIndex faceIndex
        pos = world.posAtIndex index
        return @moveBot bot, pos, face
        
    moveBot: (bot, pos, face) ->

        return if bot.type == Bot.icon
        
        if not world.isItemAtPos(pos) or world.botAtPos(pos) == bot
            index = world.indexAtPos pos
            if bot.face != face or bot.index != index
                if world.canBotMoveTo bot, face, index
                    world.moveBot bot, pos, face
                    return true
                    
module.exports = Handle
