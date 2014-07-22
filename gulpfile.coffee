path = require('path')
gulp = require('gulp')
gulpif = require('gulp-if')
gutil = require('gulp-util')
express = require('express')
coffee = require('gulp-coffee')
clean = require('gulp-clean')
watch = require('gulp-watch')
tiny_lr = require('tiny-lr')
conn_lr = require("connect-livereload")
httpPort = 4000

gulp.task 'clean', ->
  gulp.src('dist', {read: false})
  .pipe(clean())

gulp.task 'build-tests', ->
  gulp.src('./test/specs-coffee/*')
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulp.dest('./test/specs/'));

gulp.task 'build', ['build-tests'], ->
  gulp.src('./src/*')
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulp.dest('./dist/'));

gulp.task 'default', ['build'], ->
  servers = createServers(httpPort, 35729)
  # When /src changes, fire off a rebuild
  gulp.watch ['./src/**/*','./test/specs-coffee/*'], (evt) -> gulp.run 'build'
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






