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
            
    toString: (v) ->
        
        for k in @keys
            if @[k] == v
                return k

module.exports = 
    
    Bend: new Enum
        flat:       0
        concave:    1
        convex:     2
    
    Face: new Enum
        PX:         0
        PY:         1
        PZ:         2
        NX:         3
        NY:         4
        NZ:         5
                
    Stone: new Enum
        red:        0
        gelb:       1
        blue:       2
        white:      3
        gray:       4
        resources:  [0,1,2,3]
        all:        [0..4]
        
    Bot: new Enum
        base:       1
        mine:       2
        trade:      3
        build:      4
        brain:      5
        
    Geom: new Enum
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

