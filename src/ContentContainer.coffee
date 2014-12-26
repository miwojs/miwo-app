class ContentContainer extends Miwo.Container

	componentCls: 'miwo-views'
	role: 'main'


	addedComponent: (component) ->
		super(component)
		component.el.addClass('miwo-views-item')
		return


	doRender: ->
		super
		@el.setStyle('overflow', 'auto')
		return


module.exports = ContentContainer