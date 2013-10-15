Spine = require 'spine'
isMobile = require 'is-mobile'

class Controller extends Spine.Controller


	@jQuery: null


	constructor: (el = null) ->
		if !@el && el instanceof Controller.jQuery then @el = el

		super(@, [])

		@el.data('controller', @)


	@init: (jQuery, scope = '[data-application]:first') ->
		Controller.jQuery = jQuery
		Controller.jQuery.fn.hasAttr = (name) ->
			attr = $(@).attr(name)
			return typeof attr != 'undefined' && attr != false
		Controller.jQuery.fn.getController = -> return Controller.jQuery(@).data('controller')

		if scope != false then Controller.refresh(scope)


	getAllEvents: ->
		events = if @events then @events else {}
		context = @
		while parent_prototype = context.constructor.__super__
			events = Controller.jQuery.extend({}, parent_prototype.events, events) if parent_prototype.events
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
		scope = Controller.jQuery(scope)
		result = []
		result.push(scope) if scope.hasAttr('data-controller')

		scope.find('*[data-controller]').each( (i, el) ->
			el = Controller.jQuery(el)
			result.push el
		)

		return result


	@refresh: (scope = 'html') ->
		for el in Controller.findElementsWithController(scope)
			Controller.register(el.attr('data-controller'), el)


	@unbind: (scope = 'html') ->
		for el in Controller.findElementsWithController(scope)
			controller = el.data('_controller')

			controller.unbind()
			controller.stopListening()
			controller.unbindUiEvents()

			el.data('_controller', null)


	@register: (path, el = null) ->
		el = Controller.jQuery(el) if el != null

		computer = el.hasAttr('data-computer')
		mobile = el.hasAttr('data-mobile')
		if el != null && (computer || mobile)
			if computer && isMobile() then return false
			if mobile && !isMobile() then return false

		return Controller.createController(path, el)


	@createController: (name, el) ->
		return new (require(name))(el)


module.exports = Controller