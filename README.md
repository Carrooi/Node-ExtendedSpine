# extended-spine

Extended [spine](https://npmjs.org/package/spine) framework. It gives you ability to instantiate controllers almost
like in [Angular](http://angularjs.org/).

You can use it for example with [SimQ](https://npmjs.org/package/simq).

## Installation

```
$ npm install extended-spine
```

## Setup

Before everything, you have to add this one line of code into your javascript.

```
Controller = require 'extended-spine'
Controller.init($)
```

## Usage

Now only spine controller is extended.

```
Controller = require 'extended-spine/Controller'

class MyController extends Controller

	constructor: (@el) ->
		super


module.exports = MyController
```

As you can see, everything is same like in classic spine, only extended class is different.

## Creating controllers from data-controller attribute

This module will automatically look for elements in your page with `data-application` attribute. If it will not find it, whole html page will
be used. Every element inside this `data-application` element with `data-controller` element will be used for controller.
Example is much better for explain.

```
...
<div data-application>
	...
	<div data-controller="/path/to/controller/for/this/element">...</div>
	...
</div>
...
```

Text in `data-controller` attribute is path used in require method.

This means that now you don't have to instantiate controllers on your own. :-)

## Refreshing elements

If your application uses for example ajax for repainting elements, you can use two methods, showed below for refreshing
your controllers.

```
Controller = require 'extended-spine/Controller'
Controller.init($)

el = $('#element-which-will-be-repainted')

$.get(url, (data) ->
	Controller.unbind(el)
	el.html(data)
	Controller.refresh(el)
)
```

Methods `unbind` and `refresh` manipulates also with element on which it was called. You can of course disable that.

```
Controller.unbind(el, false)
Controller.refresh(el, false)
```

## Finding controllers

From jQuery element:
```
menu = $('#menu').getController()
// or
menu = $('[data-controller="/app/controller/Menu"]').getController()
```

Otherwise:
```
menu = Controller.find('/app/controller/Menu')
```

## Lazy controllers
If you don't want to instantiate some controller immediately, you can add html attribute `data-lazy` to.

```
<div data-controller="/path/to/my/controller" data-lazy></div>
```

Now when you want to create instance of this controller, you have to get it's controller factory and use it.

```
factory = Controller.find('/path/to/my/controller')		// for lazy controllers, factory function is returned
controller = factory()									// just call it and it will return created controller
```

## Mobile/computer specific controllers

You can also set if some of your controllers is only for mobile or only for computers.

```
<div data-controller="/app/controllers/just/for/mobile" data-mobile>
<div data-controller="/app/controllers/just/for/computer" data-computer>
```

## Tests

```
$ npm test
```

## Changelog

* 1.2.0
	+ Tests modules does not need to be installed globally
	+ Some updates
	+ Added find method
	+ Added lazy controller option
	+ Added lazy option

* 1.1.0
	+ Automatically creates html id
	+ Some optimization

* 1.0.4
	+ Wrong variable names

* 1.0.2 - 1.0.3
	+ Bug with inheritance

* 1.0.1
	+ Typo in tests
	+ Better documentation

* 1.0.0
	+ Initial version