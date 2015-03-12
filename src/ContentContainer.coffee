class ContentContainer extends Miwo.Container

	baseCls: 'miwo-views'
	role: 'main'
	contentEl: 'div'


	addedComponent: (component) ->
		super(component)
		component.el.addClass(@getBaseCls('item'))
		return


module.exports = ContentContainer