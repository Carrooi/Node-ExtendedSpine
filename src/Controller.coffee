Spine = require 'spine'
isMobile = require 'is-mobile'

$ = null

class Controller extends Spine.Controller


	constructor: (el = null) ->
		if !@el && el instanceof $ then @el = el

		super(@, [])

		@el.data('controller', @)


	@init: (jQuery, scope = '[data-application]:first') ->
		$ = jQuery

		$.fn.hasAttr = (name) ->
			attr = $(@).attr(name)
			return typeof attr != 'undefined' && attr != false
			
		$.fn.getController = ->
			return $(@).data('controller')

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


	@findElementsWithController: (scope = 'html') ->
		scope = $(scope)
		result = []
		result.push(scope) if scope.hasAttr('data-controller')

		scope.find('*[data-controller]').each( (i, el) =>
			el = $(el)
			result.push el
		)

		return result


	@refresh: (scope = 'html') ->
		for el in @findElementsWithController(scope)
			@register(el.attr('data-controller'), el)


	@unbind: (scope = 'html') ->
		for el in @findElementsWithController(scope)
			controller = el.data('_controller')

			controller.unbind()
			controller.stopListening()
			controller.unbindUiEvents()

			el.data('_controller', null)


	@register: (path, el = null) ->
		el = $(el) if el != null

		computer = el.hasAttr('data-computer')
		mobile = el.hasAttr('data-mobile')
		if el != null && (computer || mobile)
			if computer && isMobile() then return false
			if mobile && !isMobile() then return false

		return @createController(path, el)


	@createController: (name, el) ->
		return new (require(name))(el)


module.exports = Controller