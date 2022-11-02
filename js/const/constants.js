// monsterkodi/kode 0.243.0

var _k_ = {list: function (l) {return l != null ? typeof l.length === 'number' ? l : [] : []}}

class Enum
{
    constructor (e)
    {
        var key

        this.keys = Object.keys(e)
        this.values = []
        var list = _k_.list(this.keys)
        for (var _15_16_ = 0; _15_16_ < list.length; _15_16_++)
        {
            key = list[_15_16_]
            this[key] = e[key]
            this.values.push(e[key])
        }
    }

    string (v)
    {
        var k

        var list = _k_.list(this.keys)
        for (var _21_14_ = 0; _21_14_ < list.length; _21_14_++)
        {
            k = list[_21_14_]
            if (this[k] === v)
            {
                return k
            }
        }
    }

    keyForValue (v)
    {
        var key

        var list = _k_.list(this.keys)
        for (var _27_16_ = 0; _27_16_ < list.length; _27_16_++)
        {
            key = list[_27_16_]
            if (this[key] === v)
            {
                return key
            }
        }
    }
}
