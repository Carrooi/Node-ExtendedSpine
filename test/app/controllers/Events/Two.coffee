Controller = require './One'

class Two extends Controller


	events:
		'mouseover div span': 'onMouseover'


	onMouseover: (e) ->


module.exports = Two