###
 0000000   0000000    0000000   00000000   0000000
000       000   000  000        000       000     
000       000000000  000  0000  0000000   0000000 
000       000   000  000   000  000            000
 0000000  000   000   0000000   00000000  0000000 
###

{ valid, post, log } = require 'kxk'

{ Bot } = require './constants'

Vector    = require './lib/vector'
Materials = require './materials'
Geometry  = require './geometry'
Science   = require './science'

class Cages

    constructor: (@world) ->

        post.on 'scienceFinished', @onScienceFinished
        post.on 'botState',        @onBotState
        
    onScienceFinished: (info) =>
        
        [science, key] = Science.split info.scienceKey
        if key == 'radius'
            for bot in @world.botsOfType Bot[science], info.player
                @updateCage bot
        if info.scienceKey in ['path.length', 'tube.free']
            for type in Bot.caged
                for bot in @world.botsOfType type, info.player
                    @updateCage bot
    
    onBotState: (type, state, player) =>
        # log "onBotState #{Bot.string type} #{player} #{state}"
        if type in Bot.caged
            for bot in @world.botsOfType type, player
                @updateCage bot
            
    moveBot: (bot) ->
        
        @updateCage bot
        if bot.type == Bot.base
            for berta in @world.botsOfType Bot.berta, bot.player
                @updateCage berta
                
    updateCage: (bot) ->
        
        return if bot.type not in Bot.caged
        
        @removeCage bot
        
        return if Science.needsTube(bot) and not bot.path
        
        if bot.state == 'on'
            bot.cage = @cage bot, science(bot.player)[Bot.string bot.type].radius
            bot.cage.position.copy bot.pos

    removeCage: (bot) -> 
        
        bot?.cage?.parent.remove bot.cage
        delete bot?.cage
        
    cage: (bot, s) ->
        
        # isInside = (s) -> (pos) -> Math.round(pos.paris(vec())) <= s
        isInside = (s) -> (pos) -> Math.round(pos.manhattan(vec())) <= s
                    
        geom = @envelope bot.pos, isInside(s)
        if bot.player
            mat = Materials.cage.enemy[Bot.string bot.type]
        else
            mat = Materials.cage.player[Bot.string bot.type]
        mesh = new THREE.Mesh geom, mat
        @world.scene.add mesh
        mesh
        
    envelope: (insidePos, isInside) ->
        
        geom = new THREE.Geometry
        
        x = 0
        while isInside insidePos.plus vec x+1,0,0
            x += 1

        index = @world.indexAtPos vec x,0,0
        size = 0.05
        visited = {}
        visited[index] = 1
        check = [index]
        while valid check
            index = check.shift()
            checkPos = @world.posAtIndex index
            for neighbor in @world.neighborsOfIndex index
                neighborPos = @world.posAtIndex neighbor
                if not isInside neighborPos
                    geom.merge Geometry.box size, checkPos.x, checkPos.y, checkPos.z
                    # checkToNeighbor = checkPos.to neighborPos
                    # n = Vector.perpNormals checkToNeighbor
                    # geom.vertices.push checkPos.plus checkToNeighbor.mul(size).plus(n[0].mul(size)).plus(n[1].mul(size))
                    # geom.vertices.push checkPos.plus checkToNeighbor.mul(size).plus(n[1].mul(size)).plus(n[2].mul(size))
                    # geom.vertices.push checkPos.plus checkToNeighbor.mul(size).plus(n[2].mul(size)).plus(n[3].mul(size))
                    # geom.vertices.push checkPos.plus checkToNeighbor.mul(size).plus(n[3].mul(size)).plus(n[0].mul(size))
                    # geom.faces.push new THREE.Face3 geom.vertices.length-1, geom.vertices.length-4, geom.vertices.length-2
                    # geom.faces.push new THREE.Face3 geom.vertices.length-4, geom.vertices.length-3, geom.vertices.length-2
                else 
                    if not visited[neighbor]
                        visited[neighbor] = 1
                        check.push neighbor
                    
        # geom.mergeVertices()
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        bufg = new THREE.BufferGeometry().fromGeometry geom
        bufg

module.exports = Cages
