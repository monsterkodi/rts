###
000000000  000   000  0000000    00000000   0000000
   000     000   000  000   000  000       000     
   000     000   000  0000000    0000000   0000000 
   000     000   000  000   000  000            000
   000      0000000   0000000    00000000  0000000 
###

{ valid, empty, first, last, log, _ } = require 'kxk'

AStar  = require './lib/astar'
Vector = require './lib/vector'
Packet = require './packet'

class Tubes

    constructor: (@world) ->
        
        @astar    = new AStar @world
        @segments = {}
        @speed    = 1.0

    # 000  000   000   0000000  00000000  00000000   000000000  
    # 000  0000  000  000       000       000   000     000     
    # 000  000 0 000  0000000   0000000   0000000       000     
    # 000  000  0000       000  000       000   000     000     
    # 000  000   000  0000000   00000000  000   000     000     
    
    insertPacket: (bot) ->
        if seg = @segmentBelowBot bot
            stone = @world.stoneBelowBot bot
            if not @isInputBlocked seg
                pck = new Packet stone, @world
                @insertPacketIntoSegment pck, seg
                pck.moveOnSegment seg
                return true
        false
        
    insertPacketIntoSegment: (pck, seg) -> seg.packets.unshift pck
        
    isInputBlocked: (seg) -> first(seg.packets)?.moved < 0.12
                
    isCrossingBlocked: (seg, pck) -> 
        
        waiting = 0
        for index in seg.in
            inSeg = @segments[index]
            if last(inSeg.packets) == pck
                continue
            if last(inSeg.packets)?.moved >= 0.88
                waiting += 1
                
        if waiting > 0
            seg.queue = [] if not seg.queue
            seg.queue.push pck if pck not in seg.queue
            if pck == first seg.queue
                return false
                
        return waiting > 0
        
    distToNext: (pck, outSeg) ->
        
        if pck.moved < 1 - 0.12
            return 0.12
            
        if @isCrossingBlocked outSeg, pck
            return 0
        
        if valid outSeg.packets
            return 1 - pck.moved + outSeg.packets[0].moved - 0.12
            
        return 0.12

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
                        nextDist = @distToNext pck, outSeg
                    else
                        nextDist = (seg.packets[pckIndex+1].moved - 0.12) - pck.moved
                        
                    moveDist = Math.min delta * @speed, nextDist
                    pck.moved += moveDist 
                    
                    if pck.moved >= 1
                        if pck == first outSeg.queue
                            outSeg.queue.shift()
                        @insertPacketIntoSegment pck, outSeg
                        seg.packets.pop()
                        pck.moved -= 1
                        pck.moveOnSegment outSeg
                    else
                        pck.moveOnSegment seg
                else
                    
                    pck.moved += delta * @speed
                    if pck.moved >= 1
                        pck = seg.packets.pop()
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
            continue if bot == @world.base
            @pathFromTo @world.base, bot
            
            if bot.path?
                fi = @world.faceIndex bot.path.points[0].face, bot.path.points[0].index
                si = @segIndex fi, fi
                fakePoints = [_.cloneDeep(bot.path.points[0]), _.clone(bot.path.points[0])]
                fakePoints[0].pos.add Vector.normals[bot.face].mul 1
                @segments[si] = 
                    index:si
                    from:0
                    to:fi
                    packets:[]
                    points:fakePoints
                    dist:bot.path.length
                    in:[]
                    out:null
            
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
                
    pathFromTo: (from, to) ->
        
        path = @astar.findPath @world.faceIndex(from.face, from.index), @world.faceIndex(to.face, to.index)
        
        if path
            to.path = 
                points: @pathPoints path
                length: path.length
            to.path.pind = []
            for pi in [0...to.path.points.length]
                if to.path.points[pi].i == 0
                    to.path.pind.push pi
        else
            delete to.path
                                    
    # 00000000    0000000   000  000   000  000000000   0000000  
    # 000   000  000   000  000  0000  000     000     000       
    # 00000000   000   000  000  000 0 000     000     0000000   
    # 000        000   000  000  000  0000     000          000  
    # 000         0000000   000  000   000     000     0000000   
    
    pathPoints: (path) ->
        
        points = []
        [lastFace, lastIndex] = @world.splitFaceIndex path[0]
        lastPos = @world.posAtIndex lastIndex
        
        aboveFace = 0.35
        
        lastPos.sub Vector.normals[lastFace].mul aboveFace
        points.push i:0, face:lastFace, index:lastIndex, pos:new Vector lastPos.x, lastPos.y, lastPos.z
        
        for i in [1...path.length]
            [nextFace, nextIndex] = @world.splitFaceIndex path[i]
            nextPos = @world.posAtIndex nextIndex
            nextPos.sub Vector.normals[nextFace].mul aboveFace
            if lastFace != nextFace
                pos1 = lastPos.plus @world.directionFaceToFace path[i-1], path[i]
                pos2 = nextPos.plus @world.directionFaceToFace path[i], path[i-1]
                lm = pos1.to(pos2).length()
                l1 = (1-lm)/2
                l2 = 1-l1
                points.push i:l1, face:lastFace, index:lastIndex, pos:new Vector pos1.x, pos1.y, pos1.z
                points.push i:l2, face:nextFace, index:nextIndex, pos:new Vector pos2.x, pos2.y, pos2.z
            points.push i:0, face:nextFace, index:nextIndex, pos:new Vector nextPos.x, nextPos.y, nextPos.z
            
            si = @segIndex path[i-1], path[i]
            if not @segments[si]
                p = 2
                if lastFace != nextFace
                    p = 4
                segPoints = points.slice points.length-p, points.length
                @segments[si] = index:si, from:path[i-1], to:path[i], packets:[], points:segPoints, dist:path.length-i, in:[], out:null
            
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