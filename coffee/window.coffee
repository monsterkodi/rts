###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, stopEvent, keyinfo, prefs, win, log, $ } = require 'kxk'

RTS = require './rts'

electron = require 'electron'
         
w = new win
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    context: (items) -> 
    onLoad: -> window.rts = new RTS $ '#main'
    
# window.ELECTRON_DISABLE_SECURITY_WARNINGS = true
window.win   = electron.remote.getCurrentWindow()
window.winID = window.win.id
    
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

onMove  = -> prefs.set 'bounds', window.win.getBounds()

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
    window.win.webContents.reloadIgnoringCache()

# 000   000  000   000  00000000  00000000  000      
# 000 0 000  000   000  000       000       000      
# 000000000  000000000  0000000   0000000   000      
# 000   000  000   000  000       000       000      
# 00     00  000   000  00000000  00000000  0000000  

onWheel = (event) ->
    
    { mod, key, combo } = keyinfo.forEvent event

    if mod == 'ctrl'
        changeFontSize -event.deltaY/100
        stopEvent event
    
window.document.addEventListener 'wheel', onWheel    

window.onresize = (event) => 
    
    log 'onresize', event.target.innerWidth, event.target.innerHeight
    rts.resized event.target.innerWidth, event.target.innerHeight
    
post.on 'menuAction', (action) ->
    
# 000  000   000  000  000000000    
# 000  0000  000  000     000       
# 000  000 0 000  000     000       
# 000  000  0000  000     000       
# 000  000   000  000     000       

post.emit 'restore'
