###
0000000    00000000    0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
0000000    0000000    000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000   000  000   000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
0000000    000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

QueueButton  = require './queuebutton'
BrainButton  = require './brainbutton'
BotMenu      = require './botmenu'

class BrainMenu extends BotMenu

    constructor: (@botButton) -> 
    
        @queue = []
        
        super @botButton
        
        post.on 'scienceQueued',   @onScienceQueued
        post.on 'scienceDequeued', @onScienceDequeued
        post.on 'scienceUpdated',  @onScienceUpdated
           
    del: ->
        
        post.removeListener 'scienceQueued',   @onScienceQueued
        post.removeListener 'scienceDequeued', @onScienceDequeued
        post.removeListener 'scienceUpdated',  @onScienceUpdated
        super()

    initButtons: ->
        
        brain = rts.world.botOfType Bot.brain
                
        for science,cfg of Science.tree
            for key,values of cfg
                
                scienceKey = science + '.' + key
                btn = @addButton scienceKey, new BrainButton @, scienceKey
                
                btn.canvas.style.left = "#{values.x*100+100}px"
                btn.canvas.style.top  = "#{values.y*100+100}px"
                
        for info in Science.queue[0]
            @addToQueue info
                
        @div.style.width  = "600px"
        @div.style.height = "500px"
        
    animate: (delta) ->
        
        for button in @queue
            button.animate delta
        
        super delta
        
    onScienceQueued:   (info) => @addToQueue   info
    onScienceDequeued: (info) => @delFromQueue info
    onScienceUpdated:  (info) => @queue[info.index]?.update()
        
    addToQueue: (info) -> 
    
        btn = new QueueButton @, info
        btn.canvas.style.left = "#{@queue.length*100}px"
        btn.canvas.style.top  = "0"
        @queue.push btn
            
    delFromQueue: (info) ->
        
        btn = @queue[info.index]
        @queue.splice info.index, 1
        btn.del()
        
        @buttons[info.scienceKey]?.update()
        
        for i in [0...@queue.length]
            @queue[i].canvas.style.left = "#{i*100}px"
        
module.exports = BrainMenu
