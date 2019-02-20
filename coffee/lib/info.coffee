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

        @trias = elem class:'infotext', parent:@elem
        @lines = elem class:'infotext', parent:@elem
        @calls = elem class:'infotext', parent:@elem
        @boxes = elem class:'infotext', parent:@elem
        @pckts = elem class:'infotext', parent:@elem
        @segmt = elem class:'infotext', parent:@elem
        @stones =elem class:'infotext', parent:@elem
        @temp   =elem class:'infotext', parent:@elem

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
        
        @calls.innerHTML = "calls: #{info.calls}"
        @trias.innerHTML = "trias: #{info.triangles}"
        @lines.innerHTML = "lines: #{info.lines}"
        @boxes.innerHTML = "boxes: #{rts.world.boxes.numBoxes()}"
        @segmt.innerHTML = "segmt: #{rts.world.tubes.getSegments().length}"
        @pckts.innerHTML = "pckts: #{rts.world.tubes.getPackets().length}"
        @stones.innerHTML = "store: #{rts.world.storage.stones}"
        @temp.innerHTML   = "temps: #{rts.world.storage.temp}"

module.exports = Info

