ContentContainer = require './ContentContainer'


class Viewport extends Miwo.Container

	id: 'viewport'
	name: 'viewport'
	layout: 'absolute'
	componentCls: 'miwo-viewport'
	contentEl: 'div'
	view: null


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


	activateView: (name) ->
		if @view
			@view.hide()
			@view.setActive(false)
		@view = @getView(name)
		@view.show()
		@view.setActive(true)
		return @view


	formatName: (name) ->
		[group, section] = name.split('.')
		return group + section.capitalize()


module.exports = Viewport