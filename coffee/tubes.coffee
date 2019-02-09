###
000000000  000   000  0000000    00000000   0000000
   000     000   000  000   000  000       000     
   000     000   000  0000000    0000000   0000000 
   000     000   000  000   000  000            000
   000      0000000   0000000    00000000  0000000 
###

{ valid, empty, last, log, _ } = require 'kxk'

AStar  = require './lib/astar'
Vector = require './lib/vector'
Packet = require './packet'

class Tubes

    constructor: (@world) ->
        
        @astar       = new AStar @world
        @segments    = {}
        @minMoveDist = 0.2
        @blockDist   = 0.12

    # 000  000   000   0000000  00000000  00000000   000000000  
    # 000  0000  000  000       000       000   000     000     
    # 000  000 0 000  0000000   0000000   0000000       000     
    # 000  000  0000       000  000       000   000     000     
    # 000  000   000  0000000   00000000  000   000     000     
    
    insertPacket: (bot) ->
        
        if seg = @segmentBelowBot bot
            if not @isBlocked seg, 0
                seg.packets.push new Packet bot, @world
                
    isBlocked: (seg, fct) -> last(seg.packets)?.moved < @minMoveDist

    #  0000000   000   000  000  00     00   0000000   000000000  00000000  
    # 000   000  0000  000  000  000   000  000   000     000     000       
    # 000000000  000 0 000  000  000000000  000000000     000     0000000   
    # 000   000  000  0000  000  000 0 000  000   000     000     000       
    # 000   000  000   000  000  000   000  000   000     000     00000000  
    
    distToNext: (seg, pckIndex) ->
        
        moved = seg.packets[pckIndex].moved
        if pckIndex > 0
            # log 'toNext', seg.packets[pckIndex-1].moved-moved
            seg.packets[pckIndex-1].moved-@blockDist-moved
        else
            if moved < 1-@minMoveDist
                # log 'first is far', 1-moved
                1-moved
            else if seg.out
                minDist = Number.MAX_VALUE
                out = @segments[seg.out]
                if valid out.packets
                    minDist = Math.min minDist, (1-moved)+out.packets[0].moved
                for index in out.in
                    inSeg = @segments[index]
                    if index != seg.index and valid inSeg.packets
                        if 1-inSeg.packets[0].moved < @blockDist
                            log 'out', index, seg.index, 1-inSeg.packets[0].moved, minDist
                            minDist = Math.min minDist, Math.max 0, 1-@blockDist-moved
                minDist
            else
                Number.MAX_VALUE
    
    animate: (delta) ->
        # log 'animate'
        segs = @getSegments()
        segs.sort (a,b) -> a.dist - b.dist
        
        for seg in segs
            
            continue if empty seg.packets
            
            for pckIndex in [0...seg.packets.length]
                
                pck = seg.packets[pckIndex]
                dst = @distToNext seg, pckIndex
                pck.moved += Math.min dst, delta #* 0.1
                
            for pckIndex in [seg.packets.length-1..0]
                
                pck = seg.packets[pckIndex]
                if pck.moved >= 1
                    # log 'next segment', seg.out
                    if seg.out
                        pck.moved -= 1
                        # log 'next', pck.moved
                        # log seg.packets.length, @segments[seg.out].packets.length
                        @segments[seg.out].packets.push seg.packets.shift()
                        # log seg.packets.length, @segments[seg.out].packets.length
                        pck.moveOnSegment @segments[seg.out]
                    else
                        log 'base!'
                        pck = seg.packets.shift()
                        pck.del()
                else
                    pck.moveOnSegment seg
                
    segmentBelowBot: (bot) ->
        
        if bot.path?
            path = bot.path
            i = path.pind[1]
            f1 = @world.faceIndex path.points[0].face, path.points[0].index
            f2 = @world.faceIndex path.points[i].face, path.points[i].index
            si = @segIndex f1, f2
            @segments[si]
        
    build: ->
        
        oldSegments = _.clone @segments
        @segments = {}
        for bot in @world.getBots()
            continue if bot == @world.base
            @pathFromTo @world.base, bot
            
        for index,segment of oldSegments
            if @segments[index]
                @segments[index].packets = segment.packets
            else
                for pck in segment.packets
                    pck.del()
                    
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
        lastSegmentIndex = null
        
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
                @segments[si] = index:si, packets:[], points:segPoints, dist:path.length-i, in:[], out:null
                if lastSegmentIndex?
                    @segments[lastSegmentIndex].out = si
                    @segments[si].in.push lastSegmentIndex
                else if i < path.length-1
                    ni = @segIndex path[i], path[i+1]
                    if @segments[ni]?
                        @segments[si].out = ni
            else if lastSegmentIndex
                @segments[si].in.push lastSegmentIndex
            lastSegmentIndex = si
            
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
