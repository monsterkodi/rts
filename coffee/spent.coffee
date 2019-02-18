###
 0000000  00000000   00000000  000   000  000000000
000       000   000  000       0000  000     000   
0000000   00000000   0000000   000 0 000     000   
     000  000        000       000  0000     000   
0000000   000        00000000  000   000     000   
###

{ empty, valid, str, log } = require 'kxk'

{ Stone, Face } = require './constants'

Vector    = require './lib/vector'
Materials = require './materials'

rotCount = 0
    
class Spent

    constructor: (@world) ->
        
        @spent = []
        @gains = []

    animate: (delta) ->  

        if valid @spent
            for i in [@spent.length-1..0]
                mesh = @spent[i]
                mesh.position.add mesh.dir.mul 0.4*delta/mesh.maxLife
                mesh.life -= delta
                s = Math.min 1.0, mesh.life
                mesh.geometry.scale s,s,s
                if mesh.life <= 0
                    @world.scene.remove mesh
                    @spent.splice i, 1
    
        if valid @gains
            for i in [@gains.length-1..0]
                mesh = @gains[i]
                mesh.life -= delta
                if not mesh.bot?
                    log 'no bot? splice!'
                    @gains.splice i, 1
                    continue
                newPos = mesh.bot.pos.faded mesh.startPos, mesh.life/mesh.maxLife
                mesh.position.copy newPos
                mesh.geometry.normalize()
                s = Math.min 0.1, 0.1*(mesh.maxLife-mesh.life)
                mesh.geometry.scale s,s,s
                s = Math.min 1.0, mesh.life
                if mesh.life <= 0
                    @world.scene.remove mesh
                    @gains.splice i, 1
                
    gainAtPosFace: (cost, pos, face) ->

        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnGain stone, stoneIndex, numStones, pos, face
                stoneIndex += 1
                      
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
             
        s = 0.05
        geom = new THREE.BoxGeometry s,s,s
         
        mesh = new THREE.Mesh geom, Materials.stone[stone]
        mesh.castShadow = true
        mesh.life = mesh.maxLife = 6
        mesh.dir = Vector.normals[@world.dirsForFace(face)[0]].clone()
        mesh.dir.rotate Vector.normals[face], rotCount+360*stoneIndex/numStones
        mesh.position.copy pos.plus mesh.dir.mul radius
        @spent.push mesh
        @world.scene.add mesh

    spawnGain: (stone, stoneIndex, numStones, pos, face) ->
             
        s = 0.001
        geom = new THREE.BoxGeometry s,s,s
         
        mesh = new THREE.Mesh geom, Materials.stone[stone]
        mesh.castShadow = true
        mesh.life = mesh.maxLife = 4
        if numStones > 1
            dir = Vector.normals[@world.dirsForFace(face)[0]].clone()
            dir.rotate Vector.normals[face], 360*stoneIndex/numStones
            mesh.startPos = pos.plus dir.plus(Vector.normals[face].mul 0.5).normal().mul 0.6
        else
            mesh.startPos = pos.plus Vector.normals[face].mul 0.5
            
        mesh.position.copy mesh.startPos
        mesh.bot = rts.world.botAtPos pos
        @gains.push mesh
        @world.scene.add mesh
        
module.exports = Spent