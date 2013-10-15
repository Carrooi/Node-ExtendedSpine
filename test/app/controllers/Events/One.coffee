Controller = require 'extended-spine/Controller'

class One extends Controller


	events:
		'mouseout': 'onMouseout'


	onMouseout: (e) ->


module.exports = One