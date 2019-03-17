###
 0000000   0000000    0000000   00000000   0000000
000       000   000  000        000       000     
000       000000000  000  0000  0000000   0000000 
000       000   000  000   000  000            000
 0000000  000   000   0000000   00000000  0000000 
###

Boxes = require './boxes'

class Cages

    constructor: () ->

        box = new THREE.BoxBufferGeometry
        @boxes = new Boxes world.scene, 3000, box, Materials.cage, false
        
        post.on 'scienceFinished',  @onScienceFinished
        post.on 'botWillBeRemoved', @removeCage
        post.on 'botState',         @onBotState
        
    onScienceFinished: (info) =>
        
        [science, key] = Science.split info.scienceKey
        if key == 'radius'
            for bot in world.botsOfType Bot[science], info.player
                @updateCage bot
        if info.scienceKey in ['path.length', 'tube.free']
            for type in Bot.caged
                for bot in world.botsOfType type, info.player
                    @updateCage bot
    
    onBotState: (type, state, player) =>

        if type in Bot.caged
            for bot in world.botsOfType type, player
                @updateCage bot
            
    moveBot: (bot) ->
        
        @updateCage bot
        if bot.type == Bot.base
            for berta in world.botsOfType Bot.berta, bot.player
                @updateCage berta
                
    updateCage: (bot) ->
        
        return if bot.type not in Bot.caged
        
        @removeCage bot
        
        return if Science.needsTube(bot.type, bot.player) and not bot.path
        
        if bot.state == 'on'
            @cage bot, science(bot.player)[Bot.string bot.type].radius

    removeCage: (bot) => 
        
        if bot?.cageBoxes?
            for box in bot.cageBoxes
                @boxes.del box
            delete bot.cageBoxes
        
    animate: (scaledDelta) ->
        
        for bot in world.allBots()
            if bot.cageBoxes
                for box in bot.cageBoxes
                    box.age += scaledDelta * config.cage.anim.speed
                    if box.age % 7 < 3
                        @boxes.setSize box, world.cageOpacity*(1-(Math.cos(2*Math.PI*(box.age % 7)/3)+1)/2)
                    else
                        @boxes.setSize box, 0
        
        @boxes.render()
        
    cage: (bot, s) ->
        
        isInside = (pos) -> Math.round(pos.manhattan(vec())) <= s
                    
        insidePos = bot.pos
        
        if bot.player
            color = Color.cage.enemy[Bot.string bot.type]
        else
            color = Color.cage.player[Bot.string bot.type]
        
        x = 0
        while isInside insidePos.plus vec x+1,0,0
            x += 1

        index = world.indexAtPos vec x,0,0
        size = 0.001
        visited = {}
        check = [index]
        
        while valid check
            
            index = check.shift()
            
            if not visited[index]
                
                visited[index] = 1
                checkPos = world.posAtIndex index
                bot.cageBoxes ?= []
                box = @boxes.add pos:checkPos.plus(insidePos), size:size, color:color
                box.age = 7-checkPos.manhattan vec()
                bot.cageBoxes.push box
            
                for neighbor in world.neighborsOfIndex index
                    neighborPos = world.posAtIndex neighbor
                    if not visited[neighbor] and isInside neighborPos
                        check.push neighbor
                    
module.exports = Cages
