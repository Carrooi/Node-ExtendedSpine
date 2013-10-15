Controller = require 'extended-spine/Controller'
Controller.init($, false)

First = require '/app/controllers/First'
Second = require '/app/controllers/Second'


describe 'Controller', ->

	describe '#findElementsWithController()', ->
		it 'should find controllers elements in test element', ->
			expect(Controller.findElementsWithController('#test').length).to.be.equal(2)

		it 'should find controllers elements in html', ->
			expect(Controller.findElementsWithController().length).to.be.equal(6)

	describe '#createController()', ->
		it 'should create controller for element', ->
			c = Controller.createController('/app/controllers/First', $('#test div:first'))
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr('data-controller')).to.be.equal('/app/controllers/First')

		it 'should create controller with constructor for element', ->
			c = Controller.createController('/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr('data-controller')).to.be.equal('/app/controllers/Second')

	describe '#register()', ->
		it 'should create controller for element', ->
			c = Controller.register('/app/controllers/First', $('#test div:first'))
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr('data-controller')).to.be.equal('/app/controllers/First')

		it 'should create controller with constructor for element', ->
			c = Controller.register('/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr('data-controller')).to.be.equal('/app/controllers/Second')

	describe '#refresh()', ->
		it 'should register all controllers in application div', ->
			Controller.refresh('[data-application]')
			expect($('#test3').getController()).to.be.an.instanceof(require('/app/controllers/Application'))
			$('#test3 div').each( (i, el) ->
				expect($(el).getController()).to.be.an.instanceof(require($(el).attr('data-controller')))
			)

	describe '#getAllEvents()', ->
		it 'should return list of parsed events from controller all it\'s parents', ->
			c = Controller.createController('/app/controllers/Events/Three', $('#test div:first'))
			expect(c.getAllEvents()).to.be.eql([
				{event: 'mouseout', selector: null, method: 'onMouseout'}
				{event: 'mouseover', selector: 'div span', method: 'onMouseover'}
				{event: 'click', selector: null, method: 'onClick'}
			])

	describe '#jQuery.getController()', ->
		it 'should get registered controller from element', ->
			el = $('#test div:first')
			Controller.register('/app/controllers/First', el)
			expect(el.getController()).to.be.an.instanceof(First)