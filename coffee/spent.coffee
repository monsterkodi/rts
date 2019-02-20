###
 0000000  00000000   00000000  000   000  000000000
000       000   000  000       0000  000     000
0000000   00000000   0000000   000 0 000     000
     000  000        000       000  0000     000
0000000   000        00000000  000   000     000
###

{ deg2rad, valid, pos, log } = require 'kxk'


{ Stone, Face, Bot } = require './constants'

Vector    = require './lib/vector'
Color     = require './color'
Materials = require './materials'

rotCount = 0

class Spent

    constructor: (@world) ->

        @spent = []
        @gains = []
        
    animate: (delta) ->
        
        if valid @spent
            for i in [@spent.length-1..0]
                box = @spent[i]
                pos = @world.boxes.pos box
                rot = @world.boxes.rot box
                pos.add box.dir.mul 0.4*delta/box.maxLife
                box.life -= delta
                s = Math.min 1.0, box.life
                @world.boxes.setPos box, pos
                @world.boxes.setSize box, s*0.05
                @world.boxes.setRot box, rot.multiply box.rot
                if box.life <= 0
                    @world.boxes.del box
                    @spent.splice i, 1

        if valid @gains
            for i in [@gains.length-1..0]
                box = @gains[i]
                box.life -= delta
                if not box.bot?
                    log 'no bot? splice!'
                    @gains.splice i, 1
                    continue
                newPos = box.bot.pos.faded box.startPos, box.life/box.maxLife
                @world.boxes.setPos box, newPos
                s = Math.min 0.1, 0.1*(box.maxLife-box.life)
                @world.boxes.setSize box, s
                if box.life <= 0
                    @world.boxes.del box
                    @gains.splice i, 1
                    
    gainAtPosFace: (cost, pos, face) ->

        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnGain stone, stoneIndex, numStones, pos, face
                stoneIndex += 1

    costAtBot: (cost, bot) ->
        
        radius = switch bot.type
            when Bot.build then 0.10
            when Bot.trade then 0.22
            when Bot.mine  then 0.13
            when Bot.brain then 0.18
            else 0.8
        
        @costAtPosFace cost, bot.pos, bot.face, radius
                
    costAtPosFace: (cost, pos, face, radius=0.23) ->

        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        rotCount+=15
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnCost stone, stoneIndex, numStones, pos, face, radius
                stoneIndex += 1

    spawnCost: (stone, stoneIndex, numStones, pos, face, radius) ->

        dir = Vector.normals[@world.dirsForFace(face)[0]].clone()
        angle = rotCount+360*stoneIndex/numStones
        dir.rotate Vector.normals[face], angle
        
        startPos = pos.plus dir.mul radius
         
        rot = quat().setFromAxisAngle Vector.normals[face], deg2rad angle+45
        axis = Vector.normals[(face+1)%6].clone().applyQuaternion rot
        rot.premultiply quat().setFromAxisAngle axis, deg2rad 45
        
        box = @world.boxes.add pos:startPos, size:0.05, stone:stone, rot:rot
        box.dir = dir
        box.rot = quat().setFromAxisAngle Vector.normals[face], deg2rad 1
        box.life = box.maxLife = 6
        @spent.push box

    spawnGain: (stone, stoneIndex, numStones, pos, face) ->

        if numStones > 1
            dir = Vector.normals[@world.dirsForFace(face)[0]].clone()
            dir.rotate Vector.normals[face], 360*stoneIndex/numStones
            startPos = pos.plus dir.plus(Vector.normals[face].mul 0.5).normal().mul 0.6
        else
            startPos = pos.plus Vector.normals[face].mul 0.5
        
        box = @world.boxes.add pos:startPos, size:0.001, stone:stone, dir:pos.to startPos
        box.startPos = startPos
        box.bot = rts.world.botAtPos pos
        box.life = box.maxLife = 4
        @gains.push box

module.exports = Spent
