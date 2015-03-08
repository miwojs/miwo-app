class Request

	isRequest: true
	controller: null
	action: null
	view: null
	params: null

	constructor: (@controller, @action, params = {}) ->
		@params = Object.merge({}, params) # clone object


module.exports = Request