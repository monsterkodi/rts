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

        @cycls = elem class:'infoText', parent:@elem
        @trias = elem class:'infoText', parent:@elem
        @lines = elem class:'infoText', parent:@elem
        @calls = elem class:'infoText', parent:@elem
        @stone = elem class:'infoText', parent:@elem
        @boxes = elem class:'infoText', parent:@elem
        @pckts = elem class:'infoText', parent:@elem
        @segmt = elem class:'infoText', parent:@elem
        @ai    = elem class:'infoText', parent:@elem
        @store = elem class:'infoText', parent:@elem
        @temp  = elem class:'infoText', parent:@elem

        document.body.appendChild @elem
          
    del: ->
        
        @elem.remove()
        
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: (info) =>
        
        info = _.clone rts.renderer.info.render
        
        @cycls.innerHTML = "cycls: #{rts.world.cycles}"
        @calls.innerHTML = "calls: #{info.calls}"
        @trias.innerHTML = "trias: #{info.triangles}"
        @lines.innerHTML = "lines: #{info.lines}"
        @stone.innerHTML = "stone: #{_.size rts.world.stones}"
        @boxes.innerHTML = "boxes: #{rts.world.boxes.numBoxes()}"
        @segmt.innerHTML = "segmt: #{rts.world.tubes.getSegments().length}"
        @pckts.innerHTML = "pckts: #{rts.world.tubes.getPackets().length}"
        @ai.innerHTML    = "ai:    #{rts.world.storage[1].stones}"
        @store.innerHTML = "store: #{rts.world.storage[0].stones}"
        @temp.innerHTML  = "temps: #{rts.world.storage[0].temp}"

module.exports = Info

