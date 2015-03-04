class EventManager extends Miwo.Object

	selectors: null


	constructor: ->
		super()
		@selectors = []
		miwo.componentMgr.on('register', @bound('onRegister'))
		miwo.componentMgr.on('unregister', @bound('onUnregister'))
		return


	control: (selector, events) ->
		@selectors.push
			selector: selector
			events: events
			parts: selector.split(' ')
		return


	onRegister: (component) ->
		# match only 1-rule selectors
		for item in @selectors
			if item.parts.length is 1 && @isMatched(component, item)
				for name,event of item.events
					component.on(name, event)
		# handle multi-rules selectors
		component.on 'attached', @bound('onAttached')
		component.on 'detached', @bound('onDetached')
		return


	onUnregister: (component) ->
		# unbound events
		for item in @selectors
			if item.parts.length is 1 && @isMatched(component, item)
				for name,event of item.events
					component.un(name, event)
		# unbound events
		component.un 'attached', @bound('onAttached')
		component.un 'detached', @bound('onDetached')
		return


	onAttached: (component) ->
		# process only 1-level selectors
		for item in @selectors
			if item.parts.length > 1 && @isMatched(component, item)
				for name,event of item.events
					component.on(name, event)
		# iterate over all childs recursively
		if component.isContainer
			for child in component.getComponents().toArray()
				@onAttached(child)
		return


	onDetached: (component) ->
		# process only 1-level selectors
		for item in @selectors
			if item.parts.length > 1 && @isMatched(component, item)
				for name,event of item.events
					component.un(name, event)
		# iterate over all childs recursively
		if component.isContainer
			for child in component.getComponents().toArray()
				@onDetached(child)
		return


	isMatched: (component, item) ->
		if Type.isString(item)
			selectors = item.split(' ')
		else
			selectors = item.parts

		# test if component match last selector
		if !component.is(selectors[selectors.length-1])
			return false

		# if component match, check if has next selectors
		if selectors.length is 1
			return true

		# validate all other previous items
		component = component.getParent()
		indexLast = selectors.length-1
		for selector,index in selectors by -1
			if index is indexLast
				continue
			while component && !component.is(selector)
				component = component.getParent()
			if component is null
				return false
		return true


	doDestroy: ->
		miwo.componentMgr.un('register', @bound('onRegister'))
		miwo.componentMgr.un('unregister', @bound('onUnregister'))
		return


module.exports = EventManager