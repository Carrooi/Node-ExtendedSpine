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

	@DATA_CONTROLLER_FULL_NAME: 'data-controller-path'

	@DATA_LAZY_CONTROLLER_NAME: 'data-lazy'

	@DATA_COMPUTER_NAME: 'data-computer'

	@DATA_MOBILE_NAME: 'data-mobile'

	@DATA_INSTANCE_NAME: '__spine_controller__'

	@AUTO_ID_PREFIX: '_spine_controller'


	@di: null


	@controllers:
		__unknown__: []


	id: null

	fullName: null


	constructor: (el = null) ->
		if !@el && el instanceof $ then @el = el

		super(@, [])

		if @el && hasAttr(@el, Controller.DATA_CONTROLLER_FULL_NAME)
			@fullName = @el.attr(Controller.DATA_CONTROLLER_FULL_NAME)
		else
			Controller.controllers.__unknown__.push(@)

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
			return Controller.find($(@))

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

		scope.find("*[#{Controller.DATA_CONTROLLER_NAME}]:not([#{Controller.DATA_LAZY_CONTROLLER_NAME}])").each( (i, el) ->
			result.push($(el))
		)

		return result


	@findElementsWithLazyController: (scope = 'html', self = true) ->
		scope = $(scope)
		result = []

		if self && hasAttr(scope, Controller.DATA_LAZY_CONTROLLER_NAME)
			result.push(scope)

		scope.find("*[#{Controller.DATA_CONTROLLER_NAME}][#{Controller.DATA_LAZY_CONTROLLER_NAME}]").each( (i, el) ->
			result.push($(el))
		)

		return result


	@refresh: (scope = 'html', self = true) ->
		for el in Controller.findElementsWithController(scope, self)
			Controller.createController(el.attr(Controller.DATA_CONTROLLER_NAME), el)

		for el in Controller.findElementsWithLazyController(scope, self)
			el.data(Controller.DATA_CONTROLLER_FULL_NAME, require.resolve(el.attr(Controller.DATA_COMPUTER_NAME)))


	@unbind: (scope = 'html', self = true) ->
		for el in Controller.findElementsWithController(scope, self)
			controller = el.data(Controller.DATA_INSTANCE_NAME)

			controller.unbind()
			controller.stopListening()
			controller.unbindUiEvents()

			el.data(Controller.DATA_INSTANCE_NAME, null)


	# deprecated
	@register: (path, el = null) ->
		return Controller.createController(path, el)


	@createController: (name, el = null) ->
		el = $(el) if el != null

		computer = hasAttr(el, Controller.DATA_COMPUTER_NAME)
		mobile = hasAttr(el, Controller.DATA_MOBILE_NAME)
		if el != null && (computer || mobile)
			if computer && isMobile() then return false
			if mobile && !isMobile() then return false

		if el != null && el.length > 0 && !hasAttr(el, 'id')
			el.attr('id', Controller.AUTO_ID_PREFIX + num)
			num++

		name = require.resolve(name)
		if el != null
			el.attr(Controller.DATA_CONTROLLER_FULL_NAME, name)

		c = require(name)
		if Controller.di == null
			c = new c(el)
		else
			c = Controller.di.createInstance(c, [el])

		if typeof Controller.controllers[name] != 'undefined'
			if Object.prototype.toString.call(Controller.controllers[name]) != '[object Array]'
				Controller.controllers[name] = [Controller.controllers[name]]

			Controller.controllers[name].push(c)

		else
			Controller.controllers[name] = c

		return c


	@find: (nameOrElement) ->
		if typeof nameOrElement == 'string'
			name = nameOrElement
			fullName = require.resolve(name)

			if typeof Controller.controllers[fullName] == 'undefined'
				el = $("[#{Controller.DATA_CONTROLLER_FULL_NAME}=\"#{fullName}\"][#{Controller.DATA_LAZY_CONTROLLER_NAME}]")

				if el.length == 0
					el = $("[#{Controller.DATA_CONTROLLER_NAME}=\"#{name}\"][#{Controller.DATA_LAZY_CONTROLLER_NAME}]")
					if el.length > 0
						el.attr(Controller.DATA_CONTROLLER_FULL_NAME, fullName)

				if el.length == 0
					return null

				else if el.length == 1
					return ->
						return Controller.createController(fullName, el)

				else
					result = []
					el.each( (i, el) ->
						result.push( ->
							return Controller.createController(fullName, el)
						)
					)
					return result

			return Controller.controllers[fullName]

		else if nameOrElement instanceof $
			el = nameOrElement

			controller = el.data(Controller.DATA_INSTANCE_NAME)

			if !controller && hasAttr(el, Controller.DATA_CONTROLLER_NAME) && hasAttr(el, Controller.DATA_LAZY_CONTROLLER_NAME)
				return =>
					return Controller.createController(el.attr(Controller.DATA_CONTROLLER_NAME), el)

			return controller


module.exports = Controller