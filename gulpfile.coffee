gulp = require 'gulp'
shell = require 'gulp-shell'
watch = require 'gulp-watch'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
notify = require 'gulp-notify'
plumber = require 'gulp-plumber'
sourcemaps = require 'gulp-sourcemaps'

# Zip directory ( Working in Linux and OSX)
gulp.task 'zip', shell.task(["zip -r app.nw ."])

# Run project
gulp.task 'run', shell.task(["npm run run"])

# Compile project
gulp.task 'osx', shell.task(["npm run osx"])

# Compile project
gulp.task 'win', shell.task(["npm run win"])

# Compile project
gulp.task 'linux', shell.task(["npm run linux"])

gulp.task 'watch', ->
  gulp.src 'js/**.coffee', base: 'js'
    .pipe watch 'js/**.coffee', verbose: false, ->
      gulp.start 'build-coffee'

gulp.task 'build-coffee', ->
  gulp.src 'js/**.coffee', base: 'js'
  .pipe plumber()
  .pipe sourcemaps.init()
  .pipe coffee()
  #.pipe uglify()
  .pipe sourcemaps.write()
  .pipe gulp.dest './js'
