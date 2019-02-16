###
 0000000   00000000   0000000   00     00  00000000  000000000  00000000   000   000
000        000       000   000  000   000  000          000     000   000   000 000 
000  0000  0000000   000   000  000000000  0000000      000     0000000      00000  
000   000  000       000   000  000 0 000  000          000     000   000     000   
 0000000   00000000   0000000   000   000  00000000     000     000   000     000   
###

{ deg2rad, log, _ } = require 'kxk'

class Geometry

    @box: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.BoxGeometry size, size, size
        geom.translate x, y, z
        geom

    @star: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        
        geom.vertices.push vec(   0,  0.5, 0).normal().mul 0.5*size
        geom.vertices.push vec(-0.5, -0.3, 0).normal().mul 0.5*size
        geom.vertices.push vec( 0.5, -0.3, 0).normal().mul 0.5*size
        geom.faces.push new THREE.Face3 0, 1, 2        

        geom.vertices.push vec(   0, -0.5, 0).normal().mul 0.5*size
        geom.vertices.push vec(-0.5,  0.3, 0).normal().mul 0.5*size
        geom.vertices.push vec( 0.5,  0.3, 0).normal().mul 0.5*size
        geom.faces.push new THREE.Face3 3, 5, 4        

        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    @speed: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        geom.vertices.push vec -size/2,  size/2, size/4
        geom.vertices.push vec -size/2, -size/2, size/4
        geom.vertices.push vec  size/2,  0,      size/4
        geom.vertices.push vec -size/2,  size/2, 0
        geom.vertices.push vec  size/2,  0,      0
        geom.faces.push new THREE.Face3 0, 1, 2
        geom.faces.push new THREE.Face3 3, 0, 4
        geom.faces.push new THREE.Face3 0, 2, 4
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    @tube: (size=1, x=0, y=0, z=0) ->
        
        geom1 = new THREE.BoxGeometry size/10, size, size/10
        geom1.rotateY deg2rad 45
        geom2 = new THREE.BoxGeometry size, size/10, size/10
        geom2.rotateX deg2rad 45
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
        
    @plus: (size=1, x=0, y=0, z=0) ->

        geom1 = new THREE.BoxGeometry size/5, size, size/5
        geom2 = new THREE.BoxGeometry size, size/5, size/5
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
        
    @play: (size=1, x=0, y=0, z=0) ->
        
        geom = new THREE.Geometry
        geom.vertices.push vec -size/2,  size/2, size/4
        geom.vertices.push vec -size/2, -size/2, size/4
        geom.vertices.push vec  size/2,  0,      size/4
        geom.vertices.push vec -size/2,  size/2, 0
        geom.vertices.push vec  size/2,  0,      0
        geom.faces.push new THREE.Face3 0, 1, 2
        geom.faces.push new THREE.Face3 3, 0, 4
        geom.faces.push new THREE.Face3 0, 2, 4
        geom.computeFaceNormals()
        geom.computeFlatVertexNormals()
        geom.translate x, y, z
        geom
        
    @pause: (size=1, x=0, y=0, z=0) ->
        
        geom1  = new THREE.BoxGeometry size/3,size,size/4
        geom1.translate -size/6, 0, 0     
        geom2 = new THREE.BoxGeometry size/3,size,size/4
        geom2.translate size/6, 0, 0
        geom1.merge geom2
        geom1.translate x, y, z
        geom1
            
module.exports = Geometry
