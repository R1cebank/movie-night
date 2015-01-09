app = require('express')()
http = require('http').Server(app)
io = require('socket.io')(http)
uuid = require 'node-uuid'


angular.module('Movie-Night.server', [])
.config ->
  app.get '/', (req, res) ->
    res.send('<h1>Hello world</h1>')

.service 'MnServer', ->

  self = @
  connectedClients = []

  io.on 'connection', (socket)->
    connectedClients.push socket: socket, id: uuid.v1()
    console.log 'user connected, id: ' + connectedClients[connectedClients.length - 1].id
    socket.emit 'uuid', type : 'uuid', data: connectedClients[connectedClients.length - 1].id
    socket.on 'disconnect', ->
      console.log 'user disconnected'
    socket.on 'name', (msg) ->
      for client in connectedClients
        if client.socket == socket
          client.name = msg.data
          console.log 'client ' + client.id + ' is ' + msg.data
    socket.on 'message', (msg) ->
      io.emit 'message', msg
      console.log 'server recived:'
      console.log msg
    socket.on 'event', (msg) ->
      console.log 'event arrived time: ' + msg.timestamp
      #time adjusted
      msg.timestamp = new Date().getTime()
      console.log 'server side adjusted time: ' + msg.timestamp
      io.emit msg.type, msg
      console.log 'event ' + msg.type + ' is triggered'
    socket.on 'timeUpdate', (msg) ->
      currentClient = { }
      for client in connectedClients
        if client.socket == socket
            currentClient = client
      console.log 'timeupdated by ' + currentClient.id + ' value: ' + msg.data


  @start = ->
    http.listen 3939, ->
      console.log 'server listening on 3939'
  return @
