`/** @jsx React.DOM */`

SetIntervalMixin = require("./SetIntervalMixin.coffee")

App = React.createClass
  getDefaultProps: ->
    return

  mixins: [SetIntervalMixin]

  getInitialState: ->
    orientation = window.orientation
    orientation = 0 unless orientation
    state =
      previousOrientation: orientation
      style: 
        height: window.innerHeight
        width: window.innerWidth

    return state

  checkOrientation: ->
    orientation = window.orientation
    orientation = 0 unless orientation
    if orientation isnt @state.previousOrientation
      @setState 
        previousOrientation: orientation
      @updateDimensions()

  updateDimensions: ->
    @setState
      style:
        height: window.innerHeight
        width: window.innerWidth

  componentDidMount: ->
    window.addEventListener "resize", @updateDimensions
    window.addEventListener "orientationchange", @updateDimensions
    @setInterval @checkOrientation, 2000

  componentWillUnmount: ->
    window.removeEventListener "resize", @updateDimensions
    window.removeEventListener "orientationchange", @updateDimensions
  
  render: () ->
    `(
      <div style={this.state.style} className="container">
        Hello World
      </div>
    )`

module.exports = App