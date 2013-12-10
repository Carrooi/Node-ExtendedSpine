Spine = require 'spine'
isMobile = require 'is-mobile'

$ = null
num = 0

hasAttr = (el, name) ->
	attr = $(el).attr(name)
	return typeof attr != 'undefined' && attr != false

class Controller extends Spine.Controller


	id: null


	constructor: (el = null) ->
		if !@el && el instanceof $ then @el = el

		super(@, [])

		@id = @el.attr('id')
		@el.data('controller', @)


	@init: (jQuery, scope = '[data-application]:first') ->
		$ = jQuery
		that = @
			
		$.fn.getController = ->
			controller = $(@).data('controller')

			if !controller || typeof controller == 'string' && hasAttr($(@), 'data-controller') && hasAttr($(@), 'data-lazy')
				return =>
					return that.createController($(@).attr('data-controller'), $(@))

			return controller

		if scope != false then @refresh(scope)


	getAllEvents: ->
		events = if @events then @events else {}
		context = @
		while parent_prototype = context.constructor.__super__
			events = $.extend({}, parent_prototype.events, events) if parent_prototype.events
			context = parent_prototype

		result = []
		for event, method of events
			match = event.match(@eventSplitter)
			event = match[1]
			selector = match[2]

			result.push(
				event: event
				selector: if selector == '' then null else selector
				method: method
			)

		return result


	unbindUiEvents: ->
		for info in @getAllEvents()
			if info.selector == null
				@el.unbind(info.event)
			else
				@el.undelegate(info.selector, info.event)


	@findElementsWithController: (scope = 'html', self = true) ->
		scope = $(scope)
		result = []

		if self && hasAttr(scope, 'data-controller')
			result.push(scope)

		scope.find('*[data-controller]:not([data-lazy])').each( (i, el) =>
			el = $(el)
			result.push el
		)

		return result


	@refresh: (scope = 'html', self = true) ->
		for el in @findElementsWithController(scope, self)
			@register(el.attr('data-controller'), el)


	@unbind: (scope = 'html', self = true) ->
		for el in @findElementsWithController(scope, self)
			controller = el.data('controller')

			controller.unbind()
			controller.stopListening()
			controller.unbindUiEvents()

			el.data('controller', null)


	@register: (path, el = null) ->
		el = $(el) if el != null

		computer = hasAttr(el, 'data-computer')
		mobile = hasAttr(el, 'data-mobile')
		if el != null && (computer || mobile)
			if computer && isMobile() then return false
			if mobile && !isMobile() then return false

		if el != null && el.length > 0 && !hasAttr(el, 'id')
			el.attr('id', '_controller' + num)
			num++

		return @createController(path, el)


	@createController: (name, el) ->
		return new (require(name))(el)


	@find: (controller) ->
		return $('[data-controller="' + controller + '"]').getController()


module.exports = Controller