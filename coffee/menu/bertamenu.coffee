###
0000000    00000000  00000000   000000000   0000000   00     00  00000000  000   000  000   000
000   000  000       000   000     000     000   000  000   000  000       0000  000  000   000
0000000    0000000   0000000       000     000000000  000000000  0000000   000 0 000  000   000
000   000  000       000   000     000     000   000  000 0 000  000       000  0000  000   000
0000000    00000000  000   000     000     000   000  000   000  00000000  000   000   0000000 
###

{ post, elem, $, log } = require 'kxk'

{ Bot } = require '../constants'

BuyButton    = require './buybutton'
ToggleButton = require './togglebutton'
BotMenu      = require './botmenu'

class BertaMenu extends BotMenu

    constructor: (botButton) ->

        super botButton

        berta = rts.world.botOfType Bot.berta
        @addButton 'buy',   new BuyButton botButton, @div
        @addButton 'shoot', new ToggleButton @div, @onBertaToggle, berta.state
        
    onBertaToggle: (bertaState) =>
        
        for berta in rts.world.botsOfType Bot.berta
            berta.state = bertaState
        post.emit 'botState', 'berta', bertaState
                    
module.exports = BertaMenu
