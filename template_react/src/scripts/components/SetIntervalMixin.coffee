SetIntervalMixin =
  componentWillMount: ->
    @intervals = []
    return

  setInterval: (func, timeout) ->
    @intervals.push setInterval(func,timeout)
    return

  componentWillUnmount: ->
    @intervals.map clearInterval
    return



module.exports = SetIntervalMixin