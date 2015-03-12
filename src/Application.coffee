EventManager = require './EventManager'


class Application extends Miwo.Object

	@inject 'injector'
	@inject 'controllerFactory', 'miwo.controllerFactory'

	eventMgr: null
	componentMgr: null
	viewport: null
	rendered: false
	controllers: null
	runControllers: null
	autoCanonicalize: true


	constructor: (config) ->
		@controllers = {}
		@eventMgr = new EventManager()
		super(config)
		return


	setInjector: (@injector) ->
		if !injector.has('viewport')
			throw new Error("Missing 'viewport' service. Viewport is required to render your application")
		return


	run: (render = null) ->
		# startup controllers
		for name in @runControllers
			@getController name, (controller)=>
				# mark controllers as loaded
				@runControllers.erase(controller.name)
				# check if all controllers are loaded
				if @runControllers.length is 0
					# auto render viewport
					@render(render) if render
				return
		return


	render: (target = null) ->
		if !@rendered
			@rendered = true
			viewport = @getViewport()

			# notify beforeRender
			for name,controller of @controllers
				controller.beforeRender()

			# render viewport
			viewport.render(target || miwo.body)

			# notify afterRender
			for name,controller of @controllers
				controller.afterRender()

			# handle hash changes
			window.onhashchange = @executeRequestByHash.bind(this)
			@executeRequestByHash()
		return


	getController: (name, onReady) ->
		controller = @controllers[name]
		if !controller
			controller = @controllers[name] = @controllerFactory.create(name)
			controller.application = this
			controller.onStartup(onReady)
			controller.initialize()
		else
			controller.onStartup(onReady)
		return


	control: (target, events) ->
		if Type.isString(target)
			@eventMgr.control(target, events)
		else
			target.on(events)
		return


	getViewport: ->
		return @injector.get('viewport')


	getRouter: ->
		return @injector.get('miwo.router')


	execute: (request) ->
		@getController request.controller, (controller)=>
			controller.execute(request)
			return
		return


	forward: (request) ->
		miwo.async => @execute(request)
		return


	redirect: (request, unique) ->
		if Type.isString(request) && request.charAt(0) is '#'
			# convert hash to request
			request = @getRouter().constructRequest(request.replace(/^#/, ''))
		if !@request
			# execute request
			@redirectRequest(request, unique)
		else
			# finish request by controller
			@getController @request.controller, (controller)=>
				controller.terminate @request, =>
					@redirectRequest(request, unique)
					return
				return
		return


	redirectRequest: (request, unique) ->
		request.params._rid = Math.random().toString(36).substring(4,10) if unique
		hash = @getRouter().constructHash(request)
		@emit('request', this, request, hash)
		document.location.hash = hash
		return


	executeRequestByHash: ->
		hash = document.location.hash.substr(1)
		if !hash && !@autoCanonicalize
			return

		request = @getRouter().constructRequest(hash)
		constructedHash = @getRouter().constructHash(request)

		if @autoCanonicalize and constructedHash isnt hash
			document.location.hash = constructedHash
			return

		@execute(request)
		return


module.exports = Application