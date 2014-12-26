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
		@views = {}
		return


	# Internal initialization of controller
	# @protected
	startup: ->
		return


	# Internal rendering notification
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


	# Forward request (executed without change hash)
	# @param {String} code
	# @param {Object} params
	forward: (code, params) ->
		@request.executed = true
		@application.forward(@createRequest(code, params))
		return


	# Redirect request (hash changed)
	# @param {String} code
	# @param {Object} params
	redirect: (code, params) ->
		@request.executed = true;
		@application.redirect(@createRequest(code, params))
		return


	# Create application request
	# @private
	createRequest: (code, params) ->
		return @injector.get('miwo.requestFactory').create code, params,
			name: @name
			action: @action


	# Execute application request
	# @protected
	# @param {Miwo.app.Request} reqest
	execute: (request) ->
		@request = request
		@view = request.action

		# call action method
		actionName = @formatMethodName(request.action, 'action')
		this[actionName](request.params) if this[actionName]
		if request.executed then return

		# call render method
		renderName = @formatMethodName(@view, 'render')
		@view = @getView(@view)
		@view.activateView()
		this[renderName](request.params) if this[renderName]

		# finish request
		request.executed = true

		@lastRequest = request
		return


	getView: (name) ->
		if name
			viewport = @getViewport()
			viewName = @formatViewName(@view)
			viewport.addView(viewName, @createView(@view)) if !viewport.hasView(viewName)
			return viewport.getView(viewName)
		else
			return @view


	setView: (@view) ->
		return


	createView: (name) ->
		viewport = @getViewport()
		factory = 'create'+name.capitalize()+'View'
		if !this[factory]
			throw new Error("View #{name} has no factory method. You must define #{factory} method in controller #{this}")
		view = this[factory]({
			isView: true
			viewName: @formatViewName(name)
			id: @name+name.capitalize()+'View'
		})
		if view !instanceof Miwo.Component
			throw new Error("Created view should by instance of Miwo.Component")
		view.activateView = ->
			viewport.activateView(@viewName)
			return
		return view


	formatMethodName: (action, type) ->
		return type+action.capitalize()


	formatViewName: (action) ->
		return @name+'.'+action


module.exports = Controller