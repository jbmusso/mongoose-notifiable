TransportEventHandler = require("../transporteventhandler")


module.exports = class Transport
  constructor: (@settings, events) ->
    console.log "Building", @constructor.name

    @transportName = @getTransportName()
    @eventHandlers = @buildEventHandlers(events)


  """
  Define transport short name for easier picking of transport options, ie. "EmailTransport" becomes "email"

  @see getEventSetting() method below

  @return {String}
  """
  getTransportName: ->
    return @constructor.name.substring(0, @constructor.name.length - 9).toLowerCase()


  buildMessage: ->
    throw "Transport.buildMessage() must be overridden"


  sendMessage: ->
    throw "Transport.sendMessage() must be overridden"


  """
  EventHandlers are responsible for handling an event for a given transport.

  @return {Array}
  """
  buildEventHandlers: (events) ->
    eventHandlers = {}
    for eventName, eventSetting of events
      console.log "- Building event handler", eventName, "for", @transportName

      eventHandler = new TransportEventHandler(this, eventSetting[@transportName])
      eventHandlers[eventName] = eventHandler
    
    return eventHandlers


  getEventHandler: (event) ->
    return @eventHandlers[event.name]


  getDefaultSetting: (settingName) ->
    return @settings.defaultSettings[settingName]

