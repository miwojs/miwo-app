Miwo.app =
	Application: require './Application'
	Controller: require './Controller'
	Router: require './Router'
	Request: require './Request'
	RequestFactory: require './RequestFactory'
	FlashNotificator: require './FlashNotificator'
	EventManager: require './EventManager'
	Viewport: require './Viewport'
	ContentContainer: require './ContentContainer'


miwo.registerExtension('miwo-app', require './DiExtension')