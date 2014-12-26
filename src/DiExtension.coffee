Application = require './Application'
Router = require './Router'
RequestFactory = require './RequestFactory'
FlashNotificator = require './FlashNotificator'
ControllerFactory = require './ControllerFactory'


class MiwoAppExtension extends Miwo.di.InjectorExtension


	init: ->
		@setConfig
			flash: null
			controllers: {}
			run: []
			defaultController: 'default'
			defaultAction: 'default'
			autoCanonicalize: true
		return


	build: (injector) ->
		# setup application
		injector.define 'application', Application, (service) =>
			service.runControllers = @config.run
			service.autoCanonicalize = @config.autoCanonicalize

		injector.define 'flash', FlashNotificator, (service)=>
			service.renderer = @config.flash

		injector.define 'miwo.controllerFactory', ControllerFactory, (service)=>
			service.namespace = @config.namespace
			for name,controller of @config.controllers
				service.register(name,controller)
			return

		injector.define 'miwo.router', Router, (service) =>
			service.controller = @config.defaultController
			service.action = @config.defaultAction
			return

		injector.define 'miwo.requestFactory', RequestFactory
		return



module.exports = MiwoAppExtension