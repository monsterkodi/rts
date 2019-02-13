###
  000  000   000  00000000   0000000   
  000  0000  000  000       000   000  
  000  000 0 000  000000    000   000  
  000  000  0000  000       000   000  
  000  000   000  000        0000000   
###
{ elem, log, $}  = require 'kxk'

class Info

    constructor: ->
                    
        @elem = elem class:'info', style:'position:absolute; z-index:1; bottom:150px; left:10px'

        @trias = elem class:'infotext', parent:@elem
        @lines = elem class:'infotext', parent:@elem
        @calls = elem class:'infotext', parent:@elem
        @segmt = elem class:'infotext', parent:@elem
        @pckts = elem class:'infotext', parent:@elem
        @stones =elem class:'infotext', parent:@elem
        @temp   =elem class:'infotext', parent:@elem

        document.body.appendChild @elem
            
    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00
                
    draw: (info) =>
        
        @calls.innerHTML = "calls: #{info.calls}"
        @trias.innerHTML = "trias: #{info.triangles}"
        @lines.innerHTML = "lines: #{info.lines}"
        @segmt.innerHTML = "segmt: #{info.segments}"
        @pckts.innerHTML = "pckts: #{info.packets}"
        @stones.innerHTML = "stones: #{rts.world.storage.stones}"
        @temp.innerHTML   = "temp:   #{rts.world.storage.temp}"

module.exports = Info

