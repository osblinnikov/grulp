path = require('path')
gulp = require('gulp')
gulpif = require('gulp-if')
gutil = require('gulp-util')
express = require('express')
coffee = require('gulp-coffee')
rimraf = require('gulp-rimraf')
watch = require('gulp-watch')
tiny_lr = require('tiny-lr')
conn_lr = require("connect-livereload")
jasmine = require('gulp-jasmine')
args   = require('yargs').argv

isTestNoRun = if args.testnorun then true else false

gulp.task 'clean', ->
  gulp.src('dist', {read: false})
    .pipe(rimraf())
  gulp.src('test/specs', {read: false})
      .pipe(rimraf())

gulp.task 'build', ->
  gulp.src('./src/**/*')
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulp.dest('./dist/'))

gulp.task 'build-tests', ['build'] , ->
  gulp.src('./test/specs-coffee/*')
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulp.dest('./test/specs/'))

gulp.task 'test', ['build-tests','build'], ->
  if !isTestNoRun
    gulp.src('./test/specs/*.spec.js')
      .pipe(jasmine())

gulp.task 'default', ['build', 'build-tests', 'test'], ->
  servers = createServers(4000, 35729)
  # When /src changes, fire off a rebuild
  gulp.watch ['./src/**/*','./test/specs-coffee/*'], ['build-tests']
  # When /dist changes, tell the browser to reload
  gulp.watch ['./dist/**/*','./test/specs/*'], (evt) ->
    gutil.log(gutil.colors.cyan(evt.path), 'changed')
    servers.lr.changed
      body:
        files: [evt.path]

# Create both http server and livereload server
createServers = (port, lrport) ->
  lr = tiny_lr()
  lr.listen lrport, -> gutil.log("LiveReload listening on", lrport)
  app = express()
  app.use conn_lr()
  app.use(express.static(path.resolve("./")))
  app.listen port, ->
    gutil.log("HTTP server is listening")
    gutil.log("http://localhost:"+port+"/test/")

  lr: lr
  app: app






