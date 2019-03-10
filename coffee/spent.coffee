###
 0000000  00000000   00000000  000   000  000000000
000       000   000  000       0000  000     000
0000000   00000000   0000000   000 0 000     000
     000  000        000       000  0000     000
0000000   000        00000000  000   000     000
###

rotCount = 0

class Spent

    constructor: (@world) ->

        @spent = []
        @gains = []
        @vec = vec()
        @pos = vec()
        @rot = quat()
        
    #  0000000  000      00000000   0000000   00000000   
    # 000       000      000       000   000  000   000  
    # 000       000      0000000   000000000  0000000    
    # 000       000      000       000   000  000   000  
    #  0000000  0000000  00000000  000   000  000   000  
    
    clear: ->
        
        for box in @spent
            @world.boxes.del box

        for box in @gains
            @world.boxes.del box

        @spent = []
        @gains = []
            
    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    animate: (delta) ->

        if valid @spent
            for i in [@spent.length-1..0]
                box = @spent[i]
                @world.boxes.rot box, @rot
                @vec.copy box.dir
                @vec.scale 0.4*delta/box.maxLife
                @world.boxes.pos box, @pos
                @pos.add @vec
                box.life -= delta
                s = Math.min 1.0, box.life
                @world.boxes.setPos box, @pos
                @world.boxes.setSize box, s*0.05
                @world.boxes.setRot box, @rot.rotateAxisAngle box.rot, -60*delta
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
                @vec.copy box.bot.pos
                @vec.fade box.startPos, box.life/box.maxLife
                @world.boxes.setPos  box, @vec
                @world.boxes.setSize box, Math.min 0.1, 0.1*(box.maxLife-box.life)
                if box.life <= 0
                    @world.boxes.del box
                    @gains.splice i, 1
                    
    #  0000000    0000000   000  000   000  
    # 000        000   000  000  0000  000  
    # 000  0000  000000000  000  000 0 000  
    # 000   000  000   000  000  000  0000  
    #  0000000   000   000  000  000   000  
    
    gainAtPosFace: (cost, pos, face) ->

        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnGain stone, stoneIndex, numStones, pos, face
                stoneIndex += 1
                
    #  0000000   0000000    0000000  000000000  
    # 000       000   000  000          000     
    # 000       000   000  0000000      000     
    # 000       000   000       000     000     
    #  0000000   0000000   0000000      000     
    
    costAtBot: (cost, bot) ->
        
        radius = switch bot.type
            when Bot.build then 0.10
            when Bot.trade then 0.22
            when Bot.mine  then 0.13
            when Bot.brain then 0.18
            when Bot.berta then 0.10
            else 0.2
        
        @costAtPosFace cost, bot.pos, bot.face, radius
                
    costAtPosFace: (cost, pos, face, radius=0.23) ->

        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        rotCount -= 15
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnCost stone, stoneIndex, numStones, pos, face, radius
                stoneIndex += 1

    costAtBuild: (cost, bot) ->
        
        radius = 0.5
        numStones = 0
        cost.map (c) -> numStones += c
        stoneIndex = 0
        rotCount -= 15
        for stone in Stone.resources
            for i in [0...cost[stone]]
                @spawnCost stone, stoneIndex, numStones, bot.pos, bot.face, radius
                stoneIndex += 1
                
    #  0000000  00000000    0000000   000   000  000   000  
    # 000       000   000  000   000  000 0 000  0000  000  
    # 0000000   00000000   000000000  000000000  000 0 000  
    #      000  000        000   000  000   000  000  0000  
    # 0000000   000        000   000  00     00  000   000  
    
    spawnCost: (stone, stoneIndex, numStones, pos, face, radius) ->

        dir = Vector.normals[@world.dirsForFace(face)[0]].clone()
        angle = rotCount+360*stoneIndex/numStones
        dir.rotate Vector.normals[face], angle
                 
        @rot.setFromAxisAngle Vector.normals[face], deg2rad angle+45
        @vec.copy Vector.normals[(face+1)%6]
        @vec.applyQuaternion @rot
        @rot.premultiply Quaternion.axisAngle @vec, 45
        
        @vec.copy dir
        @vec.scale radius
        @vec.add pos
        
        box = @world.boxes.add pos:@vec, size:0.05, stone:stone, rot:@rot
        box.dir = dir
        box.rot = Vector.normals[face]
        box.life = box.maxLife = config.spent.time.cost
        @spent.push box

    spawnGain: (stone, stoneIndex, numStones, pos, face) ->

        startPos = vec()

        if numStones > 1
            @vec.copy Vector.normals[@world.dirsForFace(face)[0]]
            @vec.rotate Vector.normals[face], 360*stoneIndex/numStones
            startPos.copy Vector.normals[face]
            startPos.scale 0.5
            startPos.add @vec
            startPos.normalize()
            startPos.scale 0.6
        else
            startPos.copy Vector.normals[face]
            startPos.scale 0.5
        
        startPos.add pos    
            
        @vec.copy pos
        @vec.sub startPos
        @vec.normalize()
        box = @world.boxes.add pos:startPos, size:0.001, stone:stone, dir:@vec
        
        box.startPos = startPos
        box.bot = rts.world.botAtPos pos
        box.life = box.maxLife = config.spent.time.gain
        @gains.push box
        
module.exports = Spent
