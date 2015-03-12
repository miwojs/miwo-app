ContentContainer = require './ContentContainer'


class Viewport extends Miwo.Container

	id: 'viewport'
	name: 'viewport'
	layout: 'absolute'
	baseCls: 'miwo-viewport'
	contentEl: 'div'
	view: null
	animation: false
	animationFxIn: 'fadeIn'
	animationFxOut: 'fadeOut'
	animationDuration: 1000


	afterInit: ->
		super
		@content = @get('content', false)
		if !@content
			throw new Error("Content component missing")
		if @content !instanceof ContentContainer
			throw new Error("Content component should by instance of ContentContainer")
		return


	addContent: (config) ->
		return @add('content', new ContentContainer(config))


	hasView: (name) ->
		return !!@content.get(@formatName(name), false)


	getView: (name) ->
		return @content.get(@formatName(name))


	addView: (name, component) ->
		return @content.add(@formatName(name), component)


	activateView: (name, callback) ->
		if !@view # first view show without animation
			@view = @getView(name)
			@view.setActive(true)
			@view.show()
			callback()
			return
		@hideView =>
			@view.setActive(false)
			@view = @getView(name)
			@showView =>
				@view.setActive(true)
				callback(@view)
				return
			return
		return


	hideView: (callback) ->
		if !@view
			callback()
		if !@animation
			@view.hide()
			callback()
		else
			@view.el.addClass('animated').addClass(@animationFxOut)
			setTimeout =>
				@view.hide()
				@view.el.removeClass('animated').removeClass(@animationFxOut)
				callback()
				return
			, @animationDuration
		return


	showView: (callback) ->
		if !@animation
			@view.show()
			callback()
		else
			@view.el.addClass('animated').addClass(@animationFxIn)
			@view.show()
			callback()
			setTimeout =>
				@view.el.removeClass('animated').removeClass(@animationFxIn)
				return
			, @animationDuration
		return


	formatName: (name) ->
		[group, section] = name.split('.')
		return group + section.capitalize()


module.exports = Viewport