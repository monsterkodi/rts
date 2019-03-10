###
 0000000   0000000   000   000   0000000  000000000   0000000   000   000  000000000   0000000
000       000   000  0000  000  000          000     000   000  0000  000     000     000     
000       000   000  000 0 000  0000000      000     000000000  000 0 000     000     0000000 
000       000   000  000  0000       000     000     000   000  000  0000     000          000
 0000000   0000000   000   000  0000000      000     000   000  000   000     000     0000000 
###

class Enum
    
    constructor: (e) ->
        
        @keys = Object.keys e
        @values = []
        for key in @keys
            @[key] = e[key]
            @values.push e[key]
            
    string: (v) ->
        
        for k in @keys
            if @[k] == v
                return k
                
    keyForValue: (v) ->
        
        for key in @keys
            return key if @[key] == v

Bot = new Enum
        base:       1
        brain:      2
        trade:      3
        build:      4
        berta:      5
        mine:       6
        icon:       7
    
Bot.switchable  = [Bot.base,  Bot.brain, Bot.trade, Bot.berta]
Bot.caged       = [Bot.base,  Bot.berta]
Bot.limited     = [Bot.berta, Bot.mine]
        
Stone = new Enum
        red:        0
        gelb:       1
        blue:       2
        white:      3
        gray:       4
        monster:    5
        cancer:     6
        silver:     7
        
Stone.resources = [Stone.red, Stone.gelb, Stone.blue, Stone.white]
Stone.all       = [0..Stone.monster] # world.construct stones
        
Bend = new Enum
        flat:       0
        concave:    1
        convex:     2
    
Face = new Enum
        PX:         0
        PY:         1
        PZ:         2
        NX:         3
        NY:         4
        NZ:         5
                                
Geom = new Enum
        cube:       1
        cone:       2
        sphere:     3
        torus:      4
        icosa:      5
        dodeca:     6
        tetra:      7
        octa:       8
        cylinder:   9
        knot:       10
        dodicos:    11
        octacube:   12
        toruscone:  13
        tubecross:  14
        cubecross:  15
        
module.exports = 
    Bot:   Bot
    Bend:  Bend
    Face:  Face
    Geom:  Geom
    Stone: Stone