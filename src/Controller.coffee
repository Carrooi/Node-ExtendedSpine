Spine = require 'spine'
isMobile = require 'is-mobile'
DI = require 'dependency-injection'

$ = null
num = 0

hasAttr = (el, name) ->
	attr = $(el).attr(name)
	return typeof attr != 'undefined' && attr != false

class Controller extends Spine.Controller



	@DATA_APPLICATION_SCOPE_NAME: 'data-application'

	@DATA_CONTROLLER_NAME: 'data-controller'

	@DATA_LAZY_CONTROLLER_NAME: 'data-lazy'

	@DATA_COMPUTER_NAME: 'data-computer'

	@DATA_MOBILE_NAME: 'data-mobile'

	@DATA_INSTANCE_NAME: '__spine_controller__'

	@AUTO_ID_PREFIX: '_spine_controller'


	@di: null


	id: null

	fullName: null


	constructor: (el = null) ->
		if !@el && el instanceof $ then @el = el

		super(@, [])

		@id = @el.attr('id')
		@el.data(Controller.DATA_INSTANCE_NAME, @)


	@init: (jQuery, args...) ->
		$ = jQuery

		defaultScope = "[#{Controller.DATA_APPLICATION_SCOPE_NAME}]:first"
		defaultDi = null

		if args[0] instanceof DI
			di = args[0]
			scope = defaultScope
		else if typeof args[0] in ['string', 'boolean']
			di = if typeof args[1] == 'undefined' then defaultDi else args[1]
			scope = args[0]

		if di != null && di !instanceof DI
			throw new Error 'di container must be an instance of dependency-injection class.'

		Controller.di = di
			
		$.fn.getController = ->
			controller = $(@).data(Controller.DATA_INSTANCE_NAME)

			if !controller || typeof controller == 'string' && hasAttr($(@), Controller.DATA_CONTROLLER_NAME) && hasAttr($(@), Controller.DATA_LAZY_CONTROLLER_NAME)
				return =>
					return Controller.createController($(@).attr(Controller.DATA_CONTROLLER_NAME), $(@))

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

		if self && hasAttr(scope, Controller.DATA_CONTROLLER_NAME)
			result.push(scope)

		scope.find("*[#{Controller.DATA_CONTROLLER_NAME}]:not([#{Controller.DATA_LAZY_CONTROLLER_NAME}])").each( (i, el) =>
			el = $(el)
			result.push el
		)

		return result


	@refresh: (scope = 'html', self = true) ->
		for el in Controller.findElementsWithController(scope, self)
			Controller.register(el.attr(Controller.DATA_CONTROLLER_NAME), el)


	@unbind: (scope = 'html', self = true) ->
		for el in Controller.findElementsWithController(scope, self)
			controller = el.data(Controller.DATA_INSTANCE_NAME)

			controller.unbind()
			controller.stopListening()
			controller.unbindUiEvents()

			el.data(Controller.DATA_INSTANCE_NAME, null)


	@register: (path, el = null) ->
		el = $(el) if el != null

		computer = hasAttr(el, Controller.DATA_COMPUTER_NAME)
		mobile = hasAttr(el, Controller.DATA_MOBILE_NAME)
		if el != null && (computer || mobile)
			if computer && isMobile() then return false
			if mobile && !isMobile() then return false

		if el != null && el.length > 0 && !hasAttr(el, 'id')
			el.attr('id', Controller.AUTO_ID_PREFIX + num)
			num++

		return Controller.createController(path, el)


	@createController: (name, el) ->
		name = require.resolve(name)
		c = require(name)

		if Controller.di == null
			c = new c(el)
		else
			c = Controller.di.createInstance(c, [el])

		c.fullName = name

		return c


	@find: (controller) ->
		return $("[#{Controller.DATA_CONTROLLER_NAME}=\"#{controller}\"]").getController()


module.exports = Controller