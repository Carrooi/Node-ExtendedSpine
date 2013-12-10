Controller = require 'extended-spine/Controller'
Controller.init($, false)

First = require '/test/app/controllers/First'
Second = require '/test/app/controllers/Second'


describe 'Controller', ->

	describe '#findElementsWithController()', ->
		it 'should find controllers elements in test element', ->
			expect(Controller.findElementsWithController('#test').length).to.be.equal(2)

		it 'should find controllers elements in html', ->
			expect(Controller.findElementsWithController().length).to.be.equal(5)

	describe '#createController()', ->
		it 'should create controller for element', ->
			c = Controller.createController('/test/app/controllers/First', $('#test div:first'))
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr('data-controller')).to.be.equal('/test/app/controllers/First')

		it 'should create controller with constructor for element', ->
			c = Controller.createController('/test/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr('data-controller')).to.be.equal('/test/app/controllers/Second')

	describe '#register()', ->
		it 'should create controller for element', ->
			c = Controller.register('/test/app/controllers/First', $('#test div:first'))
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr('data-controller')).to.be.equal('/test/app/controllers/First')
			expect(c.el.attr('id')).to.have.string('_controller')

		it 'should create controller with constructor for element', ->
			c = Controller.register('/test/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr('data-controller')).to.be.equal('/test/app/controllers/Second')

	describe '#refresh()', ->
		it 'should register all controllers in application div', ->
			Controller.refresh('[data-application]')
			expect($('#test3').getController()).to.be.an.instanceof(require('/test/app/controllers/Application'))
			expect($('#test3 div:first').data('controller')).to.be.an.instanceof(require('/test/app/controllers/Fourth'))
			expect($('#test3 div:last').data('controller')).to.be.equal('/test/app/controllers/Fifth')		# lazy

	describe '#getAllEvents()', ->
		it 'should return list of parsed events from controller all it\'s parents', ->
			c = Controller.createController('/test/app/controllers/Events/Three', $('#test div:first'))
			expect(c.getAllEvents()).to.be.eql([
				{event: 'mouseout', selector: null, method: 'onMouseout'}
				{event: 'mouseover', selector: 'div span', method: 'onMouseover'}
				{event: 'click', selector: null, method: 'onClick'}
			])

	describe '#find()', ->
		it 'should find controller by its name', ->
			c = Controller.createController('/test/app/controllers/First', $('#test div:first'))
			expect(Controller.find('/test/app/controllers/First')).to.be.equal(c)

		it 'should get factory for lazy controller', ->
			factory = Controller.find('/test/app/controllers/Lazy')
			expect(factory).to.be.a('function')
			expect(factory()).to.be.an.instanceof(require('/test/app/controllers/Lazy'))

	describe '#jQuery.getController()', ->
		it 'should get registered controller from element', ->
			el = $('#test div:first')
			Controller.register('/test/app/controllers/First', el)
			expect(el.getController()).to.be.an.instanceof(First)