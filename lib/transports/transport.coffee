TransportEventHandler = require("../transporteventhandler")

module.exports = class Transport
  constructor: (@settings, events) ->
    console.log "Building", @constructor.name

    # Define transport short name for easier picking of transport options (see @getEventSetting())
    # ie "EmailTransport" -> "email"
    @transportName = @constructor.name.substring(0, @constructor.name.length - 9).toLowerCase()

    @eventHandlers = @buildEventHandlers(events)


  buildMessage: ->
    throw "Transport.buildMessage() must be overridden"


  sendMessage: ->
    throw "Transport.sendMessage() must be overridden"


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

