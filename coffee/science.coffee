###
 0000000   0000000  000  00000000  000   000   0000000  00000000
000       000       000  000       0000  000  000       000     
0000000   000       000  0000000   000 0 000  000       0000000 
     000  000       000  000       000  0000  000       000     
0000000    0000000  000  00000000  000   000   0000000  00000000
###

{ post, last, first, empty, log, _ } = require 'kxk'

{ Bot } = require './constants'

class Science

    @tree = 
        base:
            speed:  x:0, y:0, v:[0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
            prod:   x:0, y:1, v:[[1,1,1,1],[2,2,2,2],[3,3,3,3],[4,4,4,4],[6,6,6,6],[8,8,8,8]]
        brain:
            speed:  x:1, y:0, v:[0.1, 0.2, 0.4, 0.6, 0.8, 1.0]
            price:  x:1, y:1, v:[1.0, 0.9, 0.8, 0.7, 0.6, 0.5]
        trade:
            speed:  x:2, y:0, v:[0.1, 0.2, 0.4, 0.8, 1.2, 1.6]
            sell:   x:2, y:1, v:[4, 3, 2, 1]
        mine:
            speed:  x:3, y:0, v:[0.8, 1.0, 1.2, 1.4, 1.6, 2.0]
            limit:  x:3, y:1, v:[2, 4, 8, 12, 16, 32]
        build:
            cost:   x:0, y:2, v:[[0,0,0,32],[0,0,0,24],[0,0,0,20],[0,0,0,16],[0,0,0,12],[0,0,0,8]]
        tube:
            speed:  x:1, y:2, v:[0.2, 0.3, 0.5, 0.8, 1.3, 2.0]
            gap:    x:2, y:2, v:[0.2, 0.14, 0.1, 0.07, 0.05, 0.0]
        path: 
            length: x:3, y:2, v:[2, 4, 6, 8, 12, 16]
            
    @queue = []
    @maxQueue = 5

    @initState: (config) ->
        
        window.state = _.clone config
                
        state.science = {}
        state.progress = {}
        
        for science,cfg of Science.tree
            state.science[science] = {}
            state.progress[science] = {}
            for key,values of cfg
                state.science[science][key] = values.v[0]
                state.progress[science][key] = [0,0,0,0,0,0]
                
        # log 'initState', state.science

    @mineSpeed: (type) ->
        
        switch type
            when Bot.mine then state.science.mine.speed
            else state.nonMineSpeed
        
    @split: (scienceKey) -> scienceKey.split '.'
        
    @stars: (scienceKey) -> 
        
        [science,key] = @split scienceKey
        @tree[science][key].v.indexOf state.science[science][key]
        
    @nextStars: (scienceKey) ->
        
        next = @stars(scienceKey)+1
        for info in @queue
            if info.scienceKey == scienceKey
                next = info.stars+1
        next

    @maxStars: (scienceKey) -> 
        
        [science,key] = @split scienceKey
        @tree[science][key].v.length-1
            
    @enqueue: (scienceKey) ->
        
        stars = @nextStars scienceKey
        [science, key] = @split scienceKey
        if stars <= @maxStars(scienceKey) and @queue.length < @maxQueue
            c     = window.debug?.cheapScience and 1 or state.scienceCost[stars]
            times = window.debug?.fastScience and 1 or state.scienceSteps[stars]-state.progress[science][key][stars]
            cost  = [c,c,c,c]
            @queue.push scienceKey:scienceKey, stars:stars, cost:cost, times:times
            post.emit 'scienceQueued', last @queue
            true
            
    @dequeue: (info) -> 
        
        for i in [@queue.length-1..0]
            if @queue[i].scienceKey == info.scienceKey and @queue[i].stars >= info.stars
                @queue.splice i, 1
                info.index = i
                post.emit 'scienceDequeued', info
                true
            
    @currentCost: -> first(@queue)?.cost
    @deduct: -> 
        if info = first @queue
            [science,key] = @split info.scienceKey
            state.progress[science][key][info.stars] += 1
            info.times -= 1
            info.index = 0
            if info.times == 0
                @finished info
            else
                post.emit 'scienceUpdated', info
            
    @finished: (info) =>
        log 'Science.finished', info
        info.index = 0
        @queue.shift()
        
        scienceKey = info.scienceKey
        [science,key] = @split scienceKey
        
        state.science[science][key] = @tree[science][key].v[info.stars]
        switch scienceKey
            when 'path.length' then rts.world.updateTubes()
            
        post.emit 'scienceDequeued', info
            
module.exports = Science
