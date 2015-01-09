fs = require 'fs'
http = require 'http'
util = require 'util'

angular.module('Movie-Night.videoServer', [])

.service 'MnVideoServer', ->

  self= @

  @start = (path) ->
    http.createServer (req, res)->
      stat = fs.statSync(path)
      total = stat.size
      if req.headers['range']
        range = req.headers.range
        parts = range.replace /bytes=/, ''
          .split '-'
        partialstart = parts[0]
        partialend = parts[1]

        start = parseInt partialstart, 10
        end = if partialend then parseInt(partialend, 10) else total-1
        chunksize = end-start+1
        console.log 'RANGE: ' + start + '-' + end + ' = ' + chunksize

        file = fs.createReadStream path, start: start, end: end
        res.writeHead 206, 'Content-Range': 'bytes ' + start + '-' + end + '/' + total,
          'Accept-Ranges': 'bytes', 'Content-Length': chunksize, 'Content-Type': 'video/mp4'
        file.pipe(res);
      else
        console.log 'ALL: ' + total
        res.writeHead 200, 'Content-Length' : total, 'Content-Type' : 'video/mp4'
        fs.createReadStream path
          .pipe res
    .listen 1337
    console.log "Video Server Running at http://127.0.0.1:1337"
  return @
