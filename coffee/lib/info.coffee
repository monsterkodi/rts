###
  000  000   000  00000000   0000000   
  000  0000  000  000       000   000  
  000  000 0 000  000000    000   000  
  000  000  0000  000       000   000  
  000  000   000  000        0000000   
###

{ elem, log, $, _ }  = require 'kxk'

class Info

    constructor: ->
                    
        @elem = elem class:'info', style:'position:absolute; z-index:1; bottom:10px; right:20px'

        document.body.appendChild @elem
          
    del: -> @elem.remove()
        
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: (info) =>
        
        info = _.clone rts.renderer.info.render
        @elem.innerHTML = ''
        world = rts.world
        add = (text) => elem class:'infoText', parent:@elem, text:text
        add "cycls: #{world.cycles}"
        add "calls: #{info.calls}"
        add "trias: #{info.triangles}"
        # add "lines: #{info.lines}"
        add "stone: #{_.size rts.world.stones}"
        add "boxes: #{world.boxes.numBoxes()}"
        add "segmt: #{world.tubes.getSegments().length}"
        add "pckts: #{world.tubes.getPackets().length}"
        add "store: #{world.storage[0].stones}"
        # add "temps: #{world.storage[0].temp}"
        for ai in world.ai
            add "ai #{ai.player}:  #{world.storage[ai.player].stones}"

module.exports = Info

