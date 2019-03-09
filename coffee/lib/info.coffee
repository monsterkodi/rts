###
  000  000   000  00000000   0000000   
  000  0000  000  000       000   000  
  000  000 0 000  000000    000   000  
  000  000  0000  000       000   000  
  000  000   000  000        0000000   
###

class Info

    constructor: ->
                    
        @elem = elem class:'info', style:'position:absolute; z-index:1; bottom:10px; right:20px; pointer-events: none;'

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
        add "vects: #{Vector.counter}"
        add "quats: #{Quaternion.counter}"
        # add "cycls: #{world.cycles}"
        # add "calls: #{info.calls}"
        # add "trias: #{info.triangles}"
        # add "lines: #{info.lines}"
        add "stone: #{_.size rts.world.stones}"
        add "boxes: #{world.boxes.numBoxes()} / #{world.boxes.maxBoxes}"
        add "resbx: #{world.resourceBoxes.numBoxes()} / #{world.resourceBoxes.maxBoxes}"
        add "stgbx: #{rts.menu.buttons.storage.boxes.numBoxes()} / #{rts.menu.buttons.storage.boxes.maxBoxes}"
        add "cgebx: #{world.cages.boxes.numBoxes()} / #{world.cages.boxes.maxBoxes}"
        
        add "segmt: #{world.tubes.getSegments(0).length}"
        for ai in world.ai
            add "segmt#{ai.player}: #{world.tubes.getSegments(ai.player).length}"
            
        add "pckts: #{world.tubes.getPackets(0).length}"
        for ai in world.ai
            add "pckts#{ai.player}: #{world.tubes.getPackets(ai.player).length}"
            
        add "store: #{world.storage[0].stones}"
        # add "temps: #{world.storage[0].temp}"
        for ai in world.ai
            add "store#{ai.player}: #{world.storage[ai.player].stones}"
            # add "temp#{ai.player}: #{world.storage[ai.player].temp}"
        for ai in world.ai
            add "base#{ai.player}: #{ai.base.state} #{world.botOfType(Bot.base, ai.player)?.hitPoints}"
        for ai in world.ai
            add "bert#{ai.player}: #{world.botsOfType(Bot.berta, ai.player)?.length ? ''} #{world.botOfType(Bot.berta, ai.player)?.state ? ''}"
        for ai in world.ai
            add "trde#{ai.player}: #{ai.trade?.state ? ''} #{Stone.string(ai.trade?.sell) ? ''} #{Stone.string(ai.trade?.buy) ? ''}"
        for ai in world.ai
            science = Science.queue[ai.player][0]
            add "brin#{ai.player}: #{ai.brain?.state ? ''} #{science?.scienceKey ? ''} #{science?.stars ? ''}"
        for ai in world.ai
            add "task#{ai.player}: #{ai.tick} #{ai.task}"
        add '........................................'

module.exports = Info

