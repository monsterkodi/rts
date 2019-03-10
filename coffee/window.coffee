###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ win, prefs, post, keyinfo, stopEvent, log, $ } = require 'kxk'

{ Bot } = require './constants'

RTS        = require './rts'
Vector     = require './lib/vector'
Quaternion = require './lib/quaternion'
electron   = require 'electron'
    
post.setMaxListeners 20

window.vec  = (x,y,z)   -> new Vector x, y, z
window.quat = (x,y,z,w) -> new Quaternion x, y, z, w

class Window extends win
    
    onMenuAction: (action, args) =>
        
        switch action
            when 'Fullscreen' 
                window.win.setSimpleFullScreen not window.win.isSimpleFullScreen()
                if window.win.isSimpleFullScreen()
                    $("#titlebar").style.display = 'none'
                    $("#main").style.top = '0'
                    $("#main").style.borderLeft = 'none'
                    $("#main").style.borderRight = 'none'
                    $("#main").style.borderBottom = 'none'
                else
                    window.win.setWindowButtonVisibility false
                    $("#titlebar").style.display = 'flex'
                    $("#main").style.top = '30px'
                    $("#main").style.borderLeft = '6px solid #222'
                    $("#main").style.borderRight = '6px solid #222'
                    $("#main").style.borderBottom = '6px solid #222'
                window.win.webContents.focus()
        super

w = new Window
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    context: (items) -> 
    onLoad: -> 
        window.rts = new RTS $ '#main'
        
window.win = electron.remote.getCurrentWindow()

# 00000000   00000000   00000000  00000000   0000000
# 000   000  000   000  000       000       000
# 00000000   0000000    0000000   000000    0000000
# 000        000   000  000       000            000
# 000        000   000  00000000  000       0000000

if bounds = prefs.get 'bounds'
    window.win.setBounds bounds

if prefs.get 'devTools'
    window.win.webContents.openDevTools()

#  0000000   000   000   0000000  000       0000000    0000000  00000000
# 000   000  0000  000  000       000      000   000  000       000
# 000   000  000 0 000  000       000      000   000  0000000   0000000
# 000   000  000  0000  000       000      000   000       000  000
#  0000000   000   000   0000000  0000000   0000000   0000000   00000000

onMove  = -> saveBounds() 

saveBounds = -> prefs.set 'bounds', window.win.getBounds()

clearListeners = ->

    window.win.removeListener 'close', onClose
    window.win.removeListener 'move',  onMove
    window.win.webContents.removeAllListeners 'devtools-opened'
    window.win.webContents.removeAllListeners 'devtools-closed'

onClose = ->
    
    clearListeners()

#  0000000   000   000  000       0000000    0000000   0000000
# 000   000  0000  000  000      000   000  000   000  000   000
# 000   000  000 0 000  000      000   000  000000000  000   000
# 000   000  000  0000  000      000   000  000   000  000   000
#  0000000   000   000  0000000   0000000   000   000  0000000

window.onload = ->

    window.win.on 'close', onClose
    window.win.on 'move',  onMove
    window.win.webContents.on 'devtools-opened', -> prefs.set 'devTools', true
    window.win.webContents.on 'devtools-closed', -> prefs.set 'devTools'

# 00000000   00000000  000       0000000    0000000   0000000
# 000   000  000       000      000   000  000   000  000   000
# 0000000    0000000   000      000   000  000000000  000   000
# 000   000  000       000      000   000  000   000  000   000
# 000   000  00000000  0000000   0000000   000   000  0000000

reloadWin = ->

    prefs.save()
    clearListeners()
    electron.remote.getCurrentWindow()?.webContents.reloadIgnoringCache()

# 00000000   00000000   0000000  000  0000000  00000000  
# 000   000  000       000       000     000   000       
# 0000000    0000000   0000000   000    000    0000000   
# 000   000  000            000  000   000     000       
# 000   000  00000000  0000000   000  0000000  00000000  

window.onresize = (event) -> 
    
    saveBounds()
    main =$ "#main"
    br = main.getBoundingClientRect()
    rts?.resized br.width, br.height
    
# 000   000  00000000  000   000  
# 000  000   000        000 000   
# 0000000    0000000     00000    
# 000  000   000          000     
# 000   000  00000000     000     

window.onkeydown = (event) ->
    
    # log 'keydown', keyinfo.forEvent event
    switch keyinfo.forEvent(event).key
        when 'esc'   then rts.handle.loadMeta()
        when 'i'     then prefs.set 'info',  not prefs.get 'info'
        when 'x'     then rts.handle.placeBase()
        when 'z'     then rts.handle.placeBuild()
        when '1'     then rts.handle.buyBot Bot.brain
        when '2','t' then rts.handle.buyBot Bot.trade
        when '3','b' then rts.handle.buyBot Bot.berta
        when '4','m' then rts.handle.buyBot Bot.mine
        when '5'     then rts.handle.buyBot Bot.build
        when 'c', 'enter' then rts.handle.call()
        when 'd'     then prefs.set 'debug', not prefs.get 'debug'
        when 'f'     then rts.world.storage[0].fill()
        when 'e'     then rts.world.storage[0].clear()
        when 'k'     then rts.world.monsters[0]?.die()
        when 'space' then rts.togglePause()
        when '='     then rts.world.incrSpeed(); rts.world.incrSpeed()
        when '-'     then rts.world.decrSpeed(); rts.world.decrSpeed()
        when '0'     then rts.world.resetSpeed()
        when 'p'     then rts.world.plosion.atBot rts.world.bases[0]
        when 'o'     then rts.handle.enemyDeath rts.world.enemiesOfBot(rts.world.bases[0])[0]
    
post.on 'menuAction', (action) ->
    