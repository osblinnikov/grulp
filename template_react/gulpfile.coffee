path = require('path')
gulp = require('gulp')
gutil = require('gulp-util')
express = require('express')
http = require("http")
node_static = require('node-static')
sass = require('gulp-sass')
minifyCSS = require('gulp-minify-css')
clean = require('gulp-clean')
watch = require('gulp-watch')
rev = require('gulp-rev')
tiny_lr = require('tiny-lr')
conn_lr = require("connect-livereload")
webpack = require("webpack")
sockjs = require('sockjs')

webpackConfig = require("./webpack.config.js")
if gulp.env.production  # i.e. we were executed with a --production option
  webpackConfig.plugins = webpackConfig.plugins.concat(new webpack.optimize.UglifyJsPlugin())
  webpackConfig.output.filename = "main.js"
sassConfig = { includePaths : ['src/styles'] }

# paths to files in bower_components that should be copied to dist/assets/vendor
vendorPaths = ['es5-shim/es5-sham.min.js', 'es5-shim/es5-shim.min.js', 'es5-shim/es5-sham.map',
 'es5-shim/es5-shim.map']
#
# TASKS
#

gulp.task 'clean', ->
  gulp.src('dist', {read: false})
  .pipe(clean())

# main.scss should @include any other CSS you want
gulp.task 'sass', ->
  gulp.src('src/styles/main.scss')
  .pipe(sass(sassConfig).on('error', gutil.log))
  .pipe(if gulp.env.production then minifyCSS() else gutil.noop())
  # .pipe(if gulp.env.production then rev() else gutil.noop())
  .pipe(gulp.dest('dist/assets'))

# Some JS and CSS files we want to grab from Bower and put them in a dist/assets/vendor directory
# For example, the es5-sham.js is loaded in the HTML only for IE via a conditional comment.
gulp.task 'vendor', ->
  paths = vendorPaths.map (p) -> path.resolve("./bower_components", p)
  gulp.src(paths).pipe(gulp.dest('dist/assets/vendor'))

# Just copy over remaining assets to dist. Exclude the styles and scripts as we process those elsewhere
gulp.task 'copy', ->
  gulp.src(['src/**/*', '!src/scripts', '!src/scripts/**/*', '!src/styles', '!src/styles/**/*']).pipe(gulp.dest('dist'))

# This task lets Webpack take care of all the coffeescript and JSX transformations, defined in webpack.config.js
# Webpack also does its own uglification if we are in --production mode
gulp.task 'webpack', (callback) ->
  execWebpack(webpackConfig)
  callback()

gulp.task 'dev', ['build'], ->
  servers = createServers(4000, 35729)
  # When /src changes, fire off a rebuild
  gulp.watch ['./src/**/*'], (evt) -> gulp.run 'build'
  # When /dist changes, tell the browser to reload
  gulp.watch ['./dist/**/*'], (evt) ->
    gutil.log(gutil.colors.cyan(evt.path), 'changed')
    servers.lr.changed
      body:
        files: [evt.path]


gulp.task 'build', ['webpack', 'sass', 'copy', 'vendor'], ->
gulp.task 'default', ['build'], ->
  # Give first-time users a little help
  setTimeout ->
    gutil.log "**********************************************"
    gutil.log "* gulp              (development build)"
    gutil.log "* gulp clean        (rm /dist)"
    gutil.log "* gulp --production (production build)"
    gutil.log "* gulp dev          (build and run dev server)"
    gutil.log "**********************************************"
  , 3000
#
# HELPERS
#


# Create both http server and livereload server
createServers = (port, lrport) ->
  lr = tiny_lr()
  lr.listen lrport, -> gutil.log("LiveReload listening on", lrport)

  server = false
  if port > 0
    # app = express()
    # app.use conn_lr()
    # app.use(express.static(path.resolve("./dist")))
    # app.listen port, -> gutil.log("static HTTP server listening on", port)

    # 1. Echo sockjs server
    sockjs_opts = sockjs_url: "http://cdn.sockjs.org/sockjs-0.3.min.js"
    sockjs_echo = sockjs.createServer(sockjs_opts)
    sockjs_echo.on "connection", (conn) ->
      conn.on "data", (message) ->
        conn.write message
        return

      return


    # 2. Static files server
    static_directory = new node_static.Server("./dist")

    # 3. Usual http stuff
    server = http.createServer()
    server.addListener "request", (req, res) ->
      static_directory.serve req, res
      return

    server.addListener "upgrade", (req, res) ->
      res.end()
      return

    sockjs_echo.installHandlers server,
      prefix: "/ws"

    gutil.log " [*] Listening on 0.0.0.0:"+port
    server.listen port, "0.0.0.0"

  lr: lr
  app: server

execWebpack = (config) ->
  webpack config, (err, stats) ->
    if (err) then throw new gutil.PluginError("execWebpack", err)
    gutil.log("[execWebpack]", stats.toString({colors: true}))



