httpProxy = require 'http-proxy'

angular.module('Movie-Night.client', [])
.service 'MnClient', ->
  self = @
  eventHandlers = { }
  socket = { }
  userName = ''
  uuid = ''

  @join = (serverIP, port, name) ->
    #Setup video proxy server
    httpProxy.createServer target: 'http://' + serverIP + ':' + '1337'
      .listen 9393
    console.log 'client video proxy started'
    socket = io.connect 'http://' + serverIP + ':' + port
    socket.on 'message', (msg) -> self.fireEvent 'message', msg
    socket.on 'uuid', (data) -> self.fireEvent 'uuid', data
    socket.on 'videoServerStarted', (data) -> self.fireEvent 'videoServerStarted', data
    socket.on 'seeked', (data) -> self.fireEvent 'seeked', data
    socket.on 'played', (data) -> self.fireEvent 'played', data
    socket.on 'paused', (data) -> self.fireEvent 'paused', data
    self.fireEvent 'connected'
    userName = name
    @sendName name

  @sendMsg = (msg) ->
    socket.emit 'message', msg

  @sendEvent = (msg) ->
    socket.emit 'event', msg

  @send = (event, msg) ->
    socket.emit event, msg

  @on = (event, handler) ->
    eventHandlers[event] = handler

  @fireEvent = (event, data...) ->
    if eventHandlers[event]
      eventHandlers[event](data...)

  @sendName = (name) ->
    socket.emit 'name', type: 'name', data: name

  return @
