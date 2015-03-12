class Controller extends Miwo.Object

	name: null
	injector: null
	application: null
	request: null
	views: null
	view: null
	request: null
	lastRequest: null


	@service: (prop, service = null) ->
		Object.defineProperty @prototype, prop,
			get: () -> @injector.get(service || prop)
		return


	@registerView: (name, klass) ->
		@prototype['create'+name.capitalize()] = (config)->
			return new klass(config)
		return



	constructor: (config)->
		super(config)
		@startuped = false
		@onStartupCallbacks = []
		@views = {}
		return


	initialize: ->
		@startup =>
			miwo.async =>
				@startuped = true
				for callback in @onStartupCallbacks then callback(this)
				@onStartupCallbacks.empty()
				return
			return
		return


	onStartup: (callback) ->
		if !@startuped
			@onStartupCallbacks.push(callback)
		else
			miwo.async => callback(this)
		return


	# Internal initialization of controller
	# @protected
	startup: (done) ->
		done()
		return


	# Before rendering notification
	# @protected
	beforeRender: ->
		return


	# After render notification
	# @protected
	afterRender: ->
		return


	# Control object or component
	# @param {Miwo.Object|String} target
	# @param {Object} events
	control: (target, events) ->
		@application.control(target, @boundEvents(events));
		return


	# Get main application viewport
	# @returns {Miwo.component.Container}
	getViewport: () ->
		return @application.getViewport();


	# Set system container
	# @param {Miwo.di.Injector} injector
	setInjector: (@injector) ->
		return


	# Bound control events to this scope
	# @private
	boundEvents: (events) ->
		for name,callback of events
			events[name] = @boundEvent(callback)
		return events


	# Bound control event to this scope
	# @private
	boundEvent: (callback) ->
		return (args...)=> if Type.isString(callback) then this[callback].apply(this, args) else callback.apply(this, args)


	# Refresh view by name
	# @param {String} name
	refresh: (name) ->
		if @hasView(name)
			view = @getView(name)
			renderName = @formatMethodName(view.request.action, 'render')
			this[renderName](view.request, view) if this[renderName]
		return


	# Forward request (executed without change hash)
	# @param {String} code
	# @param {Object} params
	forward: (code, params) ->
		@request.executed = true  if @request # break process request
		@application.forward(@createRequest(code, params))
		return


	# Redirect request (hash changed)
	# @param {String} code
	# @param {Object} params
	# @param {Boolean} unique
	redirect: (code, params, unique) ->
		@request.executed = true  if @request # break process request
		request = if Type.isString(code) then @createRequest(code, params) else code
		@application.redirect(request, unique)
		return


	# Create application request
	# @private
	createRequest: (code, params) ->
		return @injector.get('miwo.requestFactory').create code, params,
			name: @name
			action: @action


	# Execute application request
	# @protected
	# @param {Miwo.app.Request} request
	execute: (request) ->
		@request = request
		methodName = @formatMethodName(request.action, 'show')
		if !this[methodName]
			@executeDone(request)
			return
		this[methodName] request, (view)=>
			@executeDone(request, view)
			return
		return


	# Internal callback when action is ready
	# @private
	# @param {Miwo.app.Request} request
	executeDone: (request, viewName) ->
		if request.executed then return
		request.executed = true

		# call render method
		viewName = request.action if !viewName
		request.view = viewName
		view = @getView(viewName || request.action)
		view.request = request # store last request
		@application.request = request # store last request

		@getViewport().activateView view.viewName, =>
			methodName = @formatMethodName(viewName, 'render')
			this[methodName](request, view) if this[methodName]
			return
		return


	# Terminate request (called by application, when new request need to be executed)
	# @private
	# @param {Miwo.app.Request} request
	# @param {Function} callback
	terminate: (request, callback) ->
		methodName = @formatMethodName(request.view, 'hide')
		if !this[methodName]
			miwo.async => callback()
			return
		this[methodName] request, @getView(request.view), =>
			miwo.async => callback()
			return
		return


	getView: (name) ->
		viewport = @getViewport()
		viewName = @formatViewName(name)
		viewport.addView(viewName, @createView(name)) if !viewport.hasView(viewName)
		return viewport.getView(viewName)


	hasView: (name) ->
		viewport = @getViewport()
		viewName = @formatViewName(name)
		return viewport.hasView(viewName)


	createView: (name) ->
		factory = 'create'+name.capitalize()
		if !this[factory]
			throw new Error("View #{name} has no factory method. You must define #{factory} method in controller #{this}")
		view = this[factory]()
		if view !instanceof Miwo.Component
			throw new Error("Created view should by instance of Miwo.Component")
		view.isView = true
		view.visible = false
		view.viewName = @formatViewName(name)
		view.setId(@name+name.capitalize())
		return view


	formatMethodName: (action, type) ->
		return type+action.capitalize()


	formatViewName: (action) ->
		return @name+'.'+action


module.exports = Controller