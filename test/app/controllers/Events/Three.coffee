Controller = require './Two'

class Three extends Controller


	events:
		'click': 'onClick'


	onClick: (e) ->


module.exports = Three