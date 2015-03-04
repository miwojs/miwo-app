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
		@prototype['create'+name.capitalize()+'View'] = (config)->
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
		@application.forward(@createRequest(code, params))
		return


	# Redirect request (hash changed)
	# @param {String} code
	# @param {Object} params
	# @param {Boolean} unique
	redirect: (code, params, unique) ->
		@application.redirect(@createRequest(code, params), unique)
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
		# call action method
		actionName = @formatMethodName(request.action, 'action')
		if !this[actionName]
			@executeDone(request)
			return
		this[actionName] request, (view)=>
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
		view = @getView(viewName || request.action)
		view.request = request # store last viewed request
		@getViewport().activateView view.viewName, =>
			renderName = @formatMethodName(viewName, 'render')
			this[renderName](request, view) if this[renderName]
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
		factory = 'create'+name.capitalize()+'View'
		if !this[factory]
			throw new Error("View #{name} has no factory method. You must define #{factory} method in controller #{this}")
		view = this[factory]
			isView: true
			visible: false
			viewName: @formatViewName(name)
			id: @name+name.capitalize()+'View'
		if view !instanceof Miwo.Component
			throw new Error("Created view should by instance of Miwo.Component")
		return view


	formatMethodName: (action, type) ->
		return type+action.capitalize()


	formatViewName: (action) ->
		return @name+'.'+action


module.exports = Controller