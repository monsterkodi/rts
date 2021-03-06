###
 0000000   0000000   000   000  00000000  000   0000000 
000       000   000  0000  000  000       000  000      
000       000   000  000 0 000  000000    000  000  0000
000       000   000  000  0000  000       000  000   000
 0000000   0000000   000   000  000       000   0000000 
###

module.exports = 
    
    default:
            
        volume: [0, 0.02, 0.04, 0.08, 0.12, 0.16, 0.24, 0.32, 0.48, 0.64, 0.8, 1]
        
        cage:
            boxes: size: 0.1
            anim: speed: 0.2
            
        plosion: 
            minRot:    0.01
            maxRot:    0.03
            maxAge:      12
            minSize:    0.01
            maxSize:    0.05
            maxDist:    0.6
            shrapnels:  200
        
        world:
            speed: [1/4, 1/2, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48]
            opacity: [0, 0.1, 0.3, 0.6, 0.7, 0.9, 1]
            cageOpacity: [0, 0.03, 0.05, 0.1, 0.15, 0.22, 0.3]
        
        ai: delay: 20
        
        storage:
            # stones:[ 8 *8, 8 *8, 8 *8, 8 *8]
            stones:[ 56, 64, 72, 64 ]
            # stones:[ 200,160,80,8 ]
            # stones:[80,77,13,79]
            # stones:[ 5,6,7,8 ]
            
        cancer: 
            growTime: 240
            ageTime:  120
            rotSpeed: 1
            cellsPerMonster: 2
        
        cost: 
            brain: [ 4 *8, 2 *8, 0   , 0   ]
            trade: [ 2 *8, 3 *8, 4 *8, 3 *8]
            build: [ 2 *8, 3 *8, 4 *8, 5 *8]
            mine:  [ 2 *8, 2 *8, 2 *8, 2 *8]
            berta: [ 4 *8, 5 *8, 3 *8, 2 *8]
            
        scienceCost:  [0,1,2,3,4,5]
        scienceSteps: [0,8,16,32,64,128]
            
        nonMineSpeed: 0.2
           
        base:  health: 256
        build: health: 128
        trade: health: 128
        brain: health: 64
        berta: health: 64
        mine:  health: 64
        
        spent:
            time:
                cost: 12
                gain: 8
        spark:  
            speed: 0.5
            stone: Stone.blue
            
        bullet: 
            speed: 0.1
            count: 8
            delay: 0.8
        
        monster: 
            speed:    0.2
            # speed:    0.02
            health:   32
            resource: 256
            
            
            