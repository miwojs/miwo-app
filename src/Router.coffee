Request = require './Request'


class Router extends Miwo.Object

	controller: "default"
	action: "default"


	constructRequest: (hash) ->
		match = hash.match(/^(([a-zA-Z]*)(\:([a-z][a-zA-Z]+))?(\?(.*))?)?$/)
		controller = match[2] or @controller
		action = match[4] or @action
		params = (if match[6] then @parseQuery(match[6]) else {})
		return new Request(controller, action, params)


	constructHash: (request) ->
		hash = request.controller
		if (request.action and request.action isnt @action) or (request.params and Object.getLength(request.params) > 0)
			hash += ":" + request.action
			if request.params
				query = Object.toQueryString(request.params)
				hash += "?" + query  if query
		return hash


	parseQuery: (string) ->
		query = {}
		for item in string.split('&')
			parts = item.split('=')
			query[decodeURIComponent(parts[0])] = decodeURIComponent(parts[1])
		return query


module.exports = Router