`/** @jsx React.DOM */`

# Bring in jQuery and React as a Bower component in the global namespace
require("script!react/react-with-addons.js")
require("script!jquery/jquery.js")
require("script!bootstrap/dist/js/bootstrap.js")
require("script!fastclick/lib/fastclick.js")
require("script!json2/json2.js")
require("script!lodash/dist/lodash.js")

require("bootstrap/dist/fonts/glyphicons-halflings-regular.eot")
require("bootstrap/dist/fonts/glyphicons-halflings-regular.svg")
require("bootstrap/dist/fonts/glyphicons-halflings-regular.ttf")
require("bootstrap/dist/fonts/glyphicons-halflings-regular.woff")
require("bootstrap/dist/css/bootstrap.css")
require("bootstrap/dist/css/bootstrap-theme.css")

window.addEventListener('load', ->
  FastClick.attach(document.body);
, false)


App = require("./components/App.coffee")
React.initializeTouchEvents(true);
React.renderComponent(`<App />`, document.getElementById('app'))