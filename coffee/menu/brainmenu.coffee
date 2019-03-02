###
0000000    00000000    0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
0000000    0000000    000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000   000  000   000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
0000000    000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

{ post, log } = require 'kxk'

{ Bot } = require '../constants'

QueueButton  = require './queuebutton'
BrainButton  = require './brainbutton'
BotMenu      = require './botmenu'
Science      = require '../science'

class BrainMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        @div.style.borderBottom = 'unset'
        
        @queue = []
        
        border = "#{rts.menuBorderWidth}px transparent"
        
        brain = rts.world.botOfType Bot.brain
                
        for science,cfg of Science.tree
            for key,values of cfg
                
                scienceKey = science + '.' + key
                btn = @addButton scienceKey, new BrainButton @div, scienceKey
                
                btn.canvas.style.left = "#{values.x*100+100}px"
                btn.canvas.style.top  = "#{values.y*100+100}px"
                
                if values.x == 0
                    btn.canvas.style.borderLeft = border
                if values.y == 2
                    btn.canvas.style.borderBottom = border
                    
        for info in Science.queue[0]
            @addToQueue info
                
        @div.style.width  = "500px"
        @div.style.height = "500px"
        
        post.on 'scienceQueued',   @onScienceQueued
        post.on 'scienceDequeued', @onScienceDequeued
        post.on 'scienceUpdated',  @onScienceUpdated
           
    del: ->
        post.removeListener 'scienceQueued',   @onScienceQueued
        post.removeListener 'scienceDequeued', @onScienceDequeued
        post.removeListener 'scienceUpdated',  @onScienceUpdated
        super()
        
    onScienceQueued:   (info) => @addToQueue   info
    onScienceDequeued: (info) => @delFromQueue info
    onScienceUpdated:  (info) => @queue[info.index]?.render()
        
    addToQueue: (info) -> 
    
        btn = new QueueButton @div, info
        btn.canvas.style.left = "#{@queue.length*100}px"
        btn.canvas.style.top  = "0"
        @queue.push btn
    
    delFromQueue: (info) ->
        
        btn = @queue[info.index]
        @queue.splice info.index, 1
        btn.del()
        
        @buttons[info.scienceKey]?.render()
        
        for i in [0...@queue.length]
            @queue[i].canvas.style.left = "#{i*100}px"
        
    addButton: (key, button) -> @buttons[key] = button
        
    onBrainToggle: (brainState) => 
    
        brain = rts.world.botOfType Bot.brain
        brain.state = brainState
        post.emit 'botState', 'brain', brainState
                
module.exports = BrainMenu
