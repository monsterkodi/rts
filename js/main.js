// monsterkodi/kode 0.243.0

var _k_

var app, main

app = require('kxk').app

class Main extends app
{
    constructor ()
    {
        super({dir:__dirname,dirs:['./lib','./menu'],pkg:require('../package.json'),index:'index.html',icon:'../img/app.ico',about:'../img/about.png',minWidth:1000,minHeight:740,singleWindow:true})
    }
}

main = new Main()