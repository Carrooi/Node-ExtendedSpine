[![NPM version](https://img.shields.io/npm/v/extended-spine.svg?style=flat-square)](http://badge.fury.io/js/extended-spine)
[![Dependency Status](https://img.shields.io/gemnasium/Carrooi/Node-ExtendedSpine.svg?style=flat-square)](https://gemnasium.com/Carrooi/Node-ExtendedSpine)
[![Build Status](https://img.shields.io/travis/Carrooi/Node-ExtendedSpine.svg?style=flat-square)](https://travis-ci.org/Carrooi/Node-ExtendedSpine)

# extended-spine

Extended [spine](https://npmjs.org/package/spine) framework. It gives you ability to work with controllers almost
like in [Angular](http://angularjs.org/).

You can use it for example with [SimQ](https://npmjs.org/package/simq).

## Abandoned

Unfortunately I don't have any more time to maintain this repository :-( 

![sad cat](https://raw.githubusercontent.com/sakren/sakren.github.io/master/images/sad-kitten.jpg)

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

## Using dependency-injection

If you like [dependency injection](http://en.wikipedia.org/wiki/Dependency_injection) pattern with autowired dependencies
(again for example like in angular), you can use this feature also with this module.

Uses [dependency-injection](https://github.com/sakren/node-dependency-injection) module.

```
DI = require 'dependency-injection'
di = new DI

Controller.init($, di)
```

Some controller:
```
Controller = require 'extended-spine/Controller'

class Chat extends Controller


	http: null

	jquery: null

	model: null


	constructor: (@el, @http, @jquery, @model) ->


module.exports = Chat
```

Chat module is dependent on three services. First argument will always be the container element and others will be services
from DI container.

Check [documentation](https://github.com/sakren/node-dependency-injection/blob/master/README.md) of dependency-injection
module to see how to add services into your DI container.

This works only with controllers which were created with data-controller attribute.

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

* 1.3.2
	+ Move under Carrooi organization
	+ Abandon package

* 1.3.1
	+ Bug in `init` method

* 1.3.0
	+ Refactoring
	+ Added dependency injection (package [extended-spine-di](https://github.com/sakren/node-extended-spine-di) will be removed)
	+ Added property fullName into controllers
	+ Updated dependencies
	+ Better find method

* 1.2.0
	+ Tests modules does not need to be installed globally
	+ Some updates
	+ Added find method
	+ Added lazy controller option
	+ Added lazy option
	+ Added badges
	+ Added travis

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
