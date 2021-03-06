###
 0000000   0000000  000  00000000  000   000   0000000  00000000
000       000       000  000       0000  000  000       000     
0000000   000       000  0000000   000 0 000  000       0000000 
     000  000       000  000       000  0000  000       000     
0000000    0000000  000  00000000  000   000   0000000  00000000
###

class Science

    @tree = 
        base:
            speed:  x:0, y:0, v:[0.01, 0.02, 0.04, 0.06, 0.09, 0.12]
            prod:   x:0, y:1, v:[[1,1,1,1],[2,2,2,2],[3,3,3,3],[4,4,4,4],[5,5,5,5],[6,6,6,6]]
            radius: x:0, y:2, v:[2, 3, 4, 5, 6, 7]
        berta:
            radius: x:0, y:3, v:[2, 3, 4, 5, 6, 7]
            speed:  x:1, y:3, v:[0.02, 0.04, 0.06, 0.08, 0.12, 0.20]
            limit:  x:2, y:3, v:[1, 2, 3, 4, 5, 6]
        brain:
            speed:  x:1, y:0, v:[0.1, 0.2, 0.4, 0.6, 0.8, 1.0]
        trade:
            speed:  x:2, y:0, v:[0.1, 0.2, 0.4, 0.8, 1.6, 2.4]
            sell:   x:2, y:1, v:[4, 3, 2, 1]
        mine:
            speed:  x:3, y:0, v:[0.8, 1.0, 1.2, 1.4, 1.6, 2.0]
            limit:  x:3, y:1, v:[1, 2, 3, 4, 6, 8]
        build:
            cost:   x:1, y:1, v:[[0,0,0,24],[0,0,0,16],[0,0,0,12],[0,0,0,10],[0,0,0,8],[0,0,0,4]]
        tube:
            speed:  x:1, y:2, v:[0.2, 0.25, 0.3, 0.35, 0.4,  0.5]
            gap:    x:2, y:2, v:[0.2, 0.14, 0.1, 0.07, 0.05, 0.0]
            free:   x:4, y:1, v:[0,1,2,3,4,5]
        path: 
            length: x:3, y:2, v:[2, 4, 6, 8, 12, 16]
        storage:
            capacity: x:4, y:0, v:[80, 120, 160, 200, 240, 320]
        
    @queue    = []
    @players  = []
    @maxQueue = 6

    @science: (player=0) -> Science.players[player].science

    @clear: -> 
    
        @queue = []
        @players  = []
    
    @addPlayer: ->
        
        player =
            science:  {}
            progress: {}
        
        for science,cfg of Science.tree
            player.science[science]  = {}
            player.progress[science] = {}
            for key,values of cfg
                player.science[science][key] = values.v[0]
                player.progress[science][key] = [0,0,0,0,0,0]
                
        @queue.push []
                
        @players.push player

    @needsTube: (botType, player=0) ->
        
        switch botType
            when Bot.build then level = 1
            when Bot.berta then level = 2
            else return true
            
        science(player).tube.free < level
        
    @mineSpeed: (bot) ->
        
        switch bot.type
            when Bot.mine then @science(bot.player).mine.speed
            else config.nonMineSpeed
        
    @split: (scienceKey) -> scienceKey.split '.'
        
    @stars: (scienceKey, player=0) -> 
        
        [science,key] = @split scienceKey
        @tree[science][key].v.indexOf @science(player)[science][key]
        
    @nextStars: (scienceKey, player=0) ->
        
        next = @stars(scienceKey, player)+1
        for info in @queue[player]
            if info.scienceKey == scienceKey
                next = info.stars+1
        next

    @maxStars: (scienceKey) -> 
        
        [science,key] = @split scienceKey
        @tree[science][key].v.length-1
        
    @maxValue: (scienceKey) ->
        
        [science,key] = @split scienceKey
        last @tree[science][key].v
            
    @enqueue: (scienceKey, player=0) ->
        # log "enqueue #{player} #{scienceKey}"
        stars = @nextStars scienceKey, player
        [science, key] = @split scienceKey
        if stars <= @maxStars(scienceKey,player) and @queue[player].length < @maxQueue
            c     = window.debug?.cheatScience and 1 or config.scienceCost[stars]
            times = window.debug?.cheatScience and 1 or config.scienceSteps[stars]-@players[player].progress[science][key][stars]
            cost  = [c,c,c,c]
            @queue[player].push scienceKey:scienceKey, stars:stars, cost:cost, times:times, player:player
            if player == 0
                post.emit 'scienceQueued', last @queue[player]
            true
            
    @dequeue: (info) -> 
        
        player = info.player
        for i in [@queue[player].length-1..0]
            if @queue[player][i].scienceKey == info.scienceKey and @queue[player][i].stars >= info.stars
                @queue[player].splice i, 1
                info.index = i
                if player == 0
                    post.emit 'scienceDequeued', info
                true
            
    @currentCost: (player=0) -> first(@queue[player])?.cost
    
    @deduct: (player=0) -> 
        
        if info = first @queue[player]
            [science,key] = @split info.scienceKey
            @players[player].progress[science][key][info.stars] += 1
            info.times -= 1
            info.index = 0
            if info.times == 0
                @finished info
            else
                if player == 0
                    post.emit 'scienceUpdated', info
            
    @currentProgress: (player=0) ->
        
        if info = first @queue[player]
            @progress info.scienceKey, info.stars, player
           
    @progress: (scienceKey, stars, player=0) ->
        
        [science, key] = @split scienceKey
        100*@players[player].progress[science][key][stars]/(config.scienceSteps[stars]-1)
            
    @finished: (info) =>
        # log "Science.finished #{info.player} #{info.scienceKey} #{info.stars}"
        
        player = info.player
        
        info.index = 0
        @queue[player].shift()
        
        scienceKey = info.scienceKey
        [science,key] = @split scienceKey
        
        @science(player)[science][key] = @tree[science][key].v[info.stars]
        switch scienceKey
            when 'path.length' then world.dirtyTubes()
            
        if player == 0
            post.emit 'scienceUpdated',  info
            post.emit 'scienceDequeued', info
            post.emit 'scienceFinished', info
            
module.exports = Science
