###
000000000  000   000  0000000    00000000   0000000
   000     000   000  000   000  000       000     
   000     000   000  0000000    0000000   0000000 
   000     000   000  000   000  000            000
   000      0000000   0000000    00000000  0000000 
###

{ post, valid, empty, first, last, log, _ } = require 'kxk'

{ Stone, Bend, Bot } = require './constants'

AStar    = require './lib/astar'
Vector   = require './lib/vector'
Packet   = require './packet'

class Tubes

    constructor: (@world) ->
        
        @astar    = new AStar @world
        @segments = {}

    speed: (player=0) -> science(player).tube.speed
    gap:   (player=0) -> science(player).tube.gap + 0.1
        
    # 000  000   000   0000000  00000000  00000000   000000000  
    # 000  0000  000  000       000       000   000     000     
    # 000  000 0 000  0000000   0000000   0000000       000     
    # 000  000  0000       000  000       000   000     000     
    # 000  000   000  0000000   00000000  000   000     000     
    
    insertPacket: (bot, stone) ->
        
        if seg = @segmentBelowBot bot
            stone ?= @world.stoneBelowBot bot
            # log 'insertPacket blocked', Stone.string(stone), @isInputBlocked seg
            if not @isInputBlocked seg
                pck = new Packet stone, bot.player, @world
                @insertPacketIntoSegment pck, seg
                pck.moveOnSegment seg
                return true
        # log 'insertPacketFAIL', Stone.string stone
        false
        
    insertPacketIntoSegment: (pck, seg) -> seg.packets.unshift pck
        
    isInputBlocked: (seg) -> first(seg.packets)?.moved < @gap(seg.player)
                
    isCrossingBlocked: (seg, pck) -> 
        
        waiting = 0
        for index in seg.in
            inSeg = @segments[index]
            if last(inSeg.packets) == pck
                continue
            if last(inSeg.packets)?.moved >= inSeg.moves - @gap(seg.player)
                waiting += 1
                
        if waiting > 0
            seg.queue = [] if not seg.queue
            seg.queue.push pck if pck not in seg.queue
            if pck == first seg.queue
                return false
                
        return waiting > 0
        
    distToNext: (pck, seg, outSeg) ->
        
        if pck.moved < seg.moves - @gap(seg.player)
            return @gap(seg.player)
            
        if @isCrossingBlocked outSeg, pck
            return 0
        
        if valid outSeg.packets
            return seg.moves - pck.moved + outSeg.packets[0].moved - @gap(seg.player)
            
        return @gap(seg.player)

    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
        
    animate: (delta) ->

        segs = @getSegments()
        segs.sort (a,b) -> a.dist - b.dist
        
        for seg in segs
            
            continue if empty seg.packets
            
            if seg.out
                outSeg = @segments[seg.out]
            
            for pckIndex in [seg.packets.length-1..0]
                
                pck = seg.packets[pckIndex]
                
                if outSeg
                    
                    if pckIndex == seg.packets.length-1
                        nextDist = @distToNext pck, seg, outSeg
                    else
                        nextDist = (seg.packets[pckIndex+1].moved - @gap(seg.player)) - pck.moved
                        
                    moveDist = Math.min delta * @speed(seg.player), nextDist
                    pck.move moveDist 
                    
                    if pck.moved >= seg.moves
                        if pck == first outSeg.queue
                            outSeg.queue.shift()
                        @insertPacketIntoSegment pck, outSeg
                        seg.packets.pop()
                        pck.move -seg.moves
                        pck.moveOnSegment outSeg
                    else
                        pck.moveOnSegment seg
                else
                    
                    pck.move delta * @speed(seg.player)
                    if pck.moved >= seg.moves
                        pck = seg.packets.pop()
                        @world.storage[pck.player].add pck.stone
                        pck.del()
                    else
                        pck.moveOnSegment seg
                
    segmentBelowBot: (bot) ->
        
        if bot.path?
            path = bot.path
            fi = @world.faceIndex path.points[0].face, path.points[0].index
            si = @segIndex fi, fi
            @segments[si]
        
    # 0000000    000   000  000  000      0000000    
    # 000   000  000   000  000  000      000   000  
    # 0000000    000   000  000  000      000   000  
    # 000   000  000   000  000  000      000   000  
    # 0000000     0000000   000  0000000  0000000    
    
    build: ->
        
        oldSegments = _.clone @segments
        @segments = {}
        
        for bot in @world.getBots()
            continue if bot.type == Bot.base
            
            hadPath = bot.path?
            
            @pathFromBot bot
            
            if bot.path?
                
                if not hadPath
                    post.emit 'botConnected', bot
                
                fi = @world.faceIndex bot.path.points[0].face, bot.path.points[0].index
                si = @segIndex fi, fi
                fakePoints = [_.cloneDeep(bot.path.points[0]), _.clone(bot.path.points[0])]
                fakePoints[0].pos.add Vector.normals[bot.face].mul 0.7
                @segments[si] = 
                    index:  si
                    from:   0
                    to:     fi
                    moves:  1
                    packets:[]
                    player: bot.player
                    points: fakePoints
                    dist:   bot.path.length
                    in:     []
                    out:    null
                    
            else
                if hadPath
                    post.emit 'botDisconnected', bot
            
        for index,segment of oldSegments
            if @segments[index]
                @segments[index].packets = segment.packets
            else
                for pck in segment.packets
                    pck.del()
                 
        segs = @getSegments()
        segs.sort (a,b) -> a.dist - b.dist
                    
        for index in [0...segs.length]
            seg = segs[index]
            nextIndex = index+1
            while nextIndex < segs.length
                next = segs[nextIndex]
                if next.dist > seg.dist+1
                    break
                if next.to == seg.from
                    next.out = seg.index
                    seg.in.push next.index
                nextIndex += 1
        
        # log 'build', segs.map (s) -> dist:s.dist, in:s.in, out:s.out, index:s.index, from:s.from, to:s.to#, points:s.points
                    
    # 00000000    0000000   000000000  000   000  
    # 000   000  000   000     000     000   000  
    # 00000000   000000000     000     000000000  
    # 000        000   000     000     000   000  
    # 000        000   000     000     000   000  
            
    pathFromBot: (fromBot) -> 
        
        toBot = @world.baseForBot fromBot
    
        path = @astar.findPath @world.faceIndex(fromBot.face, fromBot.index), @world.faceIndex(toBot.face, toBot.index)
        
        if path and path.length <= science(fromBot.player).path.length+1
            fromBot.path = 
                points: @pathPoints path, fromBot.player
                length: path.length
            fromBot.path.pind = []
            for pi in [0...fromBot.path.points.length]
                if fromBot.path.points[pi].i == 0
                    fromBot.path.pind.push pi
        else
            delete fromBot.path
                                                    
    # 00000000    0000000   000  000   000  000000000   0000000  
    # 000   000  000   000  000  0000  000     000     000       
    # 00000000   000   000  000  000 0 000     000     0000000   
    # 000        000   000  000  000  0000     000          000  
    # 000         0000000   000  000   000     000     0000000   
    
    pathPoints: (path, player) ->
        
        points = []
        [lastFace, lastIndex] = @world.splitFaceIndex path[0]
        lastPos = @world.posAtIndex lastIndex
        
        aboveFace = 0.35
        
        lastPos.sub Vector.normals[lastFace].mul aboveFace
        points.push i:0, face:lastFace, index:lastIndex, pos:lastPos
        
        for i in [1...path.length]
            moves = 1
            [nextFace, nextIndex] = @world.splitFaceIndex path[i]
            nextPos = @world.posAtIndex nextIndex
            nextPos.sub Vector.normals[nextFace].mul aboveFace
            if lastFace != nextFace
                pos1 = lastPos.plus @world.directionFaceToFace path[i-1], path[i]
                pos2 = nextPos.plus @world.directionFaceToFace path[i], path[i-1]
                lm = pos1.to(pos2).length()
                l1 = (1-lm)/2
                l2 = 1-l1
                points.push i:l1, face:lastFace, index:lastIndex, pos:pos1
                points.push i:l2, face:nextFace, index:nextIndex, pos:pos2
                if Bend.convex == @world.bendType path[i-1], path[i]
                    moves = 1.275
                else
                    moves = 0.66
            points.push i:0, face:nextFace, index:nextIndex, pos:nextPos
            
            si = @segIndex path[i-1], path[i]
            if not @segments[si]
                p = 2
                if lastFace != nextFace
                    p = 4
                segPoints = points.slice points.length-p, points.length
                @segments[si] = 
                    index:  si 
                    from:   path[i-1] 
                    to:     path[i] 
                    packets:[] 
                    points: segPoints
                    player: player
                    dist:   path.length-i
                    moves:  moves
                    in:     []
                    out:    null
            
            [lastFace, lastIndex] = [nextFace, nextIndex]
            lastPos = nextPos
        points

    segIndex: (fromFaceIndex,toFaceIndex) -> "#{@faceString fromFaceIndex} #{@faceString toFaceIndex}"
    faceString: (faceIndex) -> @world.stringForFaceIndex faceIndex
        
    getSegments: -> Object.values @segments
    getPackets:  -> 
        
        packets = []
        for seg in @getSegments()
            packets = packets.concat seg.packets
        packets
        
module.exports = Tubes
