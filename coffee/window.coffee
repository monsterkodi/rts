###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ win, prefs, post, keyinfo, stopEvent, log, $ } = require 'kxk'

RTS    = require './rts'
Vector = require './lib/vector'
Quaternion =require './lib/quaternion'

electron = require 'electron'
         
window.vec  = (x,y,z)   -> new Vector x, y, z
window.quat = (x,y,z,w) -> new Quaternion x, y, z, w

w = new win
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    context: (items) -> 
    onLoad: -> window.rts = new RTS $ '#main'
    
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

window.onresize = (event) -> 
    
    saveBounds()
    main =$ "#main"
    br = main.getBoundingClientRect()
    rts?.resized br.width, br.height
    
window.onkeydown = (event) ->
    
    # log 'keydown', keyinfo.forEvent event
    switch keyinfo.forEvent(event).key
        when 'i'     then prefs.set 'info',  not prefs.get 'info'
        when 'd'     then prefs.set 'debug', not prefs.get 'debug'
        when 'space' then rts.paused = not rts.paused
    
post.on 'menuAction', (action) ->
    