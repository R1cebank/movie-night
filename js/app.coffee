ip = require 'ip'


angular.module 'Movie-Night', ['Movie-Night.client', 'Movie-Night.server', 'Movie-Night.videoServer']
  .directive 'mnScrollBottom', ->
    restrict: 'A'
    link: (scope, el, attr) ->
      scope.$watchCollection attr.mnScrollBottom, ->
        el[0].scrollTop = el[0].scrollHeight

  .directive 'mnOnSeek', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      $(element).on 'seeked', ->
        scope.$eval attr.mnOnSeek, time: element[0].currentTime

  .directive 'mnOnPlay', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      $(element).on 'play', ->
        scope.$eval attr.mnOnPlay

  .directive 'mnOnPause', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      $(element).on 'pause', ->
        scope.$eval attr.mnOnPause

  .directive 'mnControl', ->
    restrict: 'A'
    scope:
      control: '=mnControl'
    link: (scope, element, attr) ->
      scope.control.time = 0
      scope.control.playing = no

      elm = element[0]
      scope.$watch 'control.playing', (newValue) ->
        if elm.readyState isnt 0
          if newValue
            console.log 'playing called'
            elm.play()
          else
            elm.pause()

      $(element).on 'play' , ->
        scope.control.playing = yes
        scope.$apply()

      $(element).on 'pause' , ->
        scope.control.playing = no
        scope.$apply()

      scope.$watch 'control.time', (newValue, oldValue) ->

        if elm.readyState isnt 0 and Math.abs(newValue - oldValue) > 1.0
          elm.currentTime = newValue

      $(element).on 'timeupdate', ->
        scope.control.time = elm.currentTime
        scope.$apply()

  .controller 'MainController', ($scope, MnClient, MnServer, MnVideoServer) ->

    $scope.messages = []
    $scope.player = time: 0, playing: no

    MnClient.on 'connected', (data) ->
      $scope.connected = yes

    MnClient.on 'uuid', (data) ->
      console.log 'recived id:' + data.data

    MnClient.on 'message', (data) ->
      console.log 'client got: '
      console.log data
      $scope.messages.push(data)
      $scope.$digest()

    MnClient.on 'played', (data) ->
      console.log data
      $scope.player.playing = yes
      $scope.$digest()

    MnClient.on 'paused', (data) ->
      console.log data
      $scope.player.playing = no
      $scope.$digest()

    MnClient.on 'videoServerStarted', (data) ->
      console.log 'video loaded'
      document.getElementById("videoWindow").load()

    MnClient.on 'seeked', (data) ->
      console.log 'recived seeked time ' + data.data
      $scope.player.time = data.data
      $scope.$digest()

    $scope.createServer = ->
      $scope.showIPInput = no
      MnServer.start()
      MnClient.join ip.address(), '3939', 'admin'
      $scope.ip = ip.address()
      $scope.videoPath = 'http://' + ip.address() + ':1337'

    $scope.submitIP = (ip) ->
      console.log ip
      MnClient.join ip, '3939'

    $scope.submitMessage = ->
      tempMsg =
        type: 'msg'
        data: $scope.messageInput
        timestamp: new Date().getTime()
      MnClient.sendMsg tempMsg
      $scope.messageInput = ''
      console.log 'client sent'
      console.log tempMsg

    $scope.onseek = (time) ->
      tempMsg =
        type: 'seeked'
        data: time
        timestamp: new Date().getTime()
      MnClient.sendEvent tempMsg

    $scope.videoPlayed = ->
      tempMsg =
        type: 'played'
        data: ''
        timestamp: new Date().getTime()
      MnClient.sendEvent tempMsg

    $scope.videoPaused = ->
      tempMsg =
        type: 'paused'
        data: ''
        timestamp: new Date().getTime()
      MnClient.sendEvent tempMsg

    $scope.file_changed = (element)->
      console.log element.files[0].path
      MnVideoServer.start element.files[0].path
      tempMsg =
        type: 'videoServerStarted'
        data: ''
        timestamp: new Date().getTime()
      MnClient.sendEvent tempMsg
