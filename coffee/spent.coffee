###
 0000000  00000000   00000000  000   000  000000000
000       000   000  000       0000  000     000
0000000   00000000   0000000   000 0 000     000
     000  000        000       000  0000     000
0000000   000        00000000  000   000     000
###

{ valid, pos, log } = require 'kxk'

{ Stone, Face } = require './constants'

Vector    = require './lib/vector'
Materials = require './materials'

rotCount = 0

class Spent

    constructor: (@world) ->

        @spent = []
        @gains = []

    init: ->
        
        instances = 100
        @geometry = new THREE.InstancedBufferGeometry()

        # per mesh data x,y,z,w,u,v,s,t for 4-element alignment
        # only use x,y,z and u,v but x, y, z, nx, ny, nz, u, v would be a good layout

        vertexBuffer = new THREE.InterleavedBuffer new Float32Array [
            # Front
            -1, 1, 1, 0, 0, 0, 0, 0,
            1, 1, 1, 0, 1, 0, 0, 0,
            -1, -1, 1, 0, 0, 1, 0, 0,
            1, -1, 1, 0, 1, 1, 0, 0,
            # Back
            1, 1, -1, 0, 1, 0, 0, 0,
            -1, 1, -1, 0, 0, 0, 0, 0,
            1, -1, -1, 0, 1, 1, 0, 0,
            -1, -1, -1, 0, 0, 1, 0, 0,
            # Left
            -1, 1, -1, 0, 1, 1, 0, 0,
            -1, 1, 1, 0, 1, 0, 0, 0,
            -1, -1, -1, 0, 0, 1, 0, 0,
            -1, -1, 1, 0, 0, 0, 0, 0,
            # Right
            1, 1, 1, 0, 1, 0, 0, 0,
            1, 1, -1, 0, 1, 1, 0, 0,
            1, -1, 1, 0, 0, 0, 0, 0,
            1, -1, -1, 0, 0, 1, 0, 0,
            # Top
            -1, 1, 1, 0, 0, 0, 0, 0,
            1, 1, 1, 0, 1, 0, 0, 0,
            -1, 1, -1, 0, 0, 1, 0, 0,
            1, 1, -1, 0, 1, 1, 0, 0,
            # Bottom
            1, -1, 1, 0, 1, 0, 0, 0,
            -1, -1, 1, 0, 0, 0, 0, 0,
            1, -1, -1, 0, 1, 1, 0, 0,
            -1, -1, -1, 0, 0, 1, 0, 0
            ], 8

        positions = new THREE.InterleavedBufferAttribute vertexBuffer, 3, 0
        @geometry.addAttribute 'position', positions
        
        uvs = new THREE.InterleavedBufferAttribute vertexBuffer, 2, 4
        @geometry.addAttribute 'uv', uvs
        
        indices = new Uint16Array [
            0, 1, 2,
            2, 1, 3,
            4, 5, 6,
            6, 5, 7,
            8, 9, 10,
            10, 9, 11,
            12, 13, 14,
            14, 13, 15,
            16, 17, 18,
            18, 17, 19,
            20, 21, 22,
            22, 21, 23
        ]
        @geometry.setIndex new THREE.BufferAttribute indices, 1

        @instanceBuffer = new THREE.InstancedInterleavedBuffer new Float32Array(instances*8), 8, 1
        @instanceBuffer.setDynamic true
        
        @offsets = new THREE.InterleavedBufferAttribute @instanceBuffer, 3, 0

        for i in [0...@offsets.count]
            x = Math.random()*5 # - 2.5
            y = Math.random()*5 # - 2.5
            z = Math.random()*5 # - 2.5
            @offsets.setXYZ i, x, y, z

        @geometry.addAttribute 'offset', @offsets
        @orientations = new THREE.InterleavedBufferAttribute @instanceBuffer, 4, 4

        vector = new THREE.Vector4()
        for i in [0...@orientations.count]
            vector.set Math.random()*2-1, Math.random()*2-1, Math.random()*2-1, Math.random()*2-1
            vector.normalize()
            @orientations.setXYZW i, vector.x, vector.y, vector.z, vector.w

        @geometry.addAttribute 'orientation', @orientations

        @mesh = new THREE.Mesh @geometry, Materials.spent
        @mesh.frustumCulled = false
        
        @instanceBuffer.needsUpdate = true
        @world.scene.add @mesh

    animate: (delta) ->

        @instanceBuffer.needsUpdate = true
        
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
