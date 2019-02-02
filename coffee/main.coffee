###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

{ app } = require 'kxk'

class Main extends app

    constructor: ->
        
        super
            dir:          __dirname
            pkg:          require '../package.json'
            index:        'index.html'
            icon:         '../img/app.ico'
            about:        '../img/about.png'
            minWidth:     500 
            singleWindow: true
            
main = new Main()
