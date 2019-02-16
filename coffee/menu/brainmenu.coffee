###
0000000    00000000    0000000   000  000   000  00     00  00000000  000   000  000   000
000   000  000   000  000   000  000  0000  000  000   000  000       0000  000  000   000
0000000    0000000    000000000  000  000 0 000  000000000  0000000   000 0 000  000   000
000   000  000   000  000   000  000  000  0000  000 0 000  000       000  0000  000   000
0000000    000   000  000   000  000  000   000  000   000  00000000  000   000   0000000 
###

{ post, log } = require 'kxk'

QueueButton  = require './queuebutton'
BrainButton  = require './brainbutton'
ToggleButton = require './togglebutton'
BotMenu      = require './botmenu'
Science      = require '../science'

class BrainMenu extends BotMenu

    constructor: (botButton) -> 
    
        super botButton
        
        @div.style.borderBottom = 'unset'
        
        @queue = []
        
        border = "#{rts.menuBorderWidth}px transparent"
        # border = "#{rts.menuBorderWidth}px solid #151500"
        
        btn = @addButton 'brain', new ToggleButton @div, @onBrainToggle, state.brain.state
        btn.canvas.style.borderBottom = border
                
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
                    
        for info in Science.queue
            @addToQueue info
                
        @div.style.width  = "500px"
        @div.style.height = "500px"
        
        post.on 'scienceQueued', @onScienceQueued
        post.on 'scienceDequeued', @onScienceDequeued
           
    del: ->
        post.removeListener 'scienceQueued', @onScienceQueued
        post.removeListener 'scienceDequeued', @onScienceDequeued
        super()
        
    onScienceQueued: (info) => @addToQueue info
    onScienceDequeued: (info) => @delFromQueue info
        
    addToQueue: (info) -> 
    
        # log 'addToQueue', info
        btn = new QueueButton @div, info, @queue.length
        btn.canvas.style.left = "#{@queue.length*100+100}px"
        btn.canvas.style.top  = "0"
        @queue.push btn
    
    delFromQueue: (info) ->
        
        # log 'delFromQueue', info
        btn = @queue[info.index]
        @queue.splice info.index, 1
        btn.del()
        
        @buttons[info.scienceKey]?.render()
        
        for i in [0...@queue.length]
            @queue[i].canvas.style.left = "#{i*100+100}px"
        
    addButton: (key, button) -> @buttons[key] = button
        
    onBrainToggle: (brainState) => state.brain.state = brainState
                
module.exports = BrainMenu
