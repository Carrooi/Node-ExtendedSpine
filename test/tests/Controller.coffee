Controller = require 'extended-spine/Controller'
DI = require 'dependency-injection'

First = require '/test/app/controllers/First'
Second = require '/test/app/controllers/Second'


describe 'Controller', ->

	beforeEach( ->
		Controller.init($, false)
	)

	afterEach( ->
		Controller.release()
	)

	describe '#findElementsWithController()', ->
		it 'should find controllers elements in test element', ->
			expect(Controller.findElementsWithController('#test').length).to.be.equal(2)

		it 'should find controllers elements in html', ->
			expect(Controller.findElementsWithController().length).to.be.equal(6)

		it 'should find controllers elements in test element except container', ->
			expect(Controller.findElementsWithController('#test3', false).length).to.be.equal(1)

	describe '#createController()', ->
		it 'should create controller for element', ->
			c = Controller.createController('/test/app/controllers/First', $('#test div:first'))
			name = '/test/app/controllers/First'
			fullName = name + '.coffee'
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr(Controller.DATA_CONTROLLER_NAME)).to.be.equal(name)
			expect(c.el.attr(Controller.DATA_CONTROLLER_FULL_NAME)).to.be.equal(fullName)
			expect(c.fullName).to.be.equal(fullName)
			expect(Controller.controllers).to.contain.keys([fullName])
			expect(Controller.controllers[fullName]).to.be.equal(c)
			expect(Controller.controllers.__unknown__).to.be.empty

		it 'should create controller with constructor for element', ->
			c = Controller.createController('/test/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr(Controller.DATA_CONTROLLER_NAME)).to.be.equal('/test/app/controllers/Second')

		it 'should create controller for element', ->
			c = Controller.createController('/test/app/controllers/First', $('#test div:first'))
			expect(c).to.be.an.instanceof(First)
			expect(c.el.attr(Controller.DATA_CONTROLLER_NAME)).to.be.equal('/test/app/controllers/First')
			expect(c.el.attr('id')).to.have.string('_controller')

		it 'should create controller with constructor for element', ->
			c = Controller.createController('/test/app/controllers/Second', $('#test div:last'))
			expect(c).to.be.an.instanceof(Second)
			expect(c.el.attr(Controller.DATA_CONTROLLER_NAME)).to.be.equal('/test/app/controllers/Second')

		it 'should create controller with autowired services', ->
			di = new DI
			di.addService('myArray', ['hello', 'word']).setInstantiate(false)

			Controller.release()
			Controller.init($, false, di)

			c = Controller.createController('/test/app/controllers/Autowired', $('#autowired'))
			expect(c.myArray).to.be.eql(['hello', 'word'])

	describe '#refresh()', ->
		it 'should register all controllers in application div', ->
			Controller.refresh("[#{Controller.DATA_APPLICATION_SCOPE_NAME}]")
			expect($('#test3').getController()).to.be.an.instanceof(require('/test/app/controllers/Application'))
			expect($('#test3 div:first').data(Controller.DATA_INSTANCE_NAME)).to.be.an.instanceof(require('/test/app/controllers/Fourth'))
			expect($('#test3 div:last').data(Controller.DATA_INSTANCE_NAME)).to.not.exists		# lazy

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
			controllers = Controller.find('/test/app/controllers/First')
			expect(controllers).to.be.equal(c)

		it 'should get factory for lazy controller', ->
			factory = Controller.find('/test/app/controllers/Lazy')
			expect(factory).to.be.a('function')
			expect(factory()).to.be.an.instanceof(require('/test/app/controllers/Lazy'))

	describe '#jQuery.getController()', ->
		it 'should get registered controller from element', ->
			el = $('#test div:first')
			Controller.createController('/test/app/controllers/First', el)
			expect(el.getController()).to.be.an.instanceof(First)