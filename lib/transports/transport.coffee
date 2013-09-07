module.exports = class Transport
  constructor: (@settings, @events) ->
    console.log "Building", @constructor.name
    console.log @settings
    console.log @events

    @transportName = @constructor.name.substring(0, @constructor.name.length - 9).toLowerCase()


  getEventSetting: (settingName, context) ->
    return @events[context.event.name][@transportName].options?[settingName]


  getTransportSetting: (settingName) ->
    return @settings[settingName]


  resolveSetting: (settingName, context) ->
    eventSetting = @getEventSetting(settingName, context)
    if eventSetting?
      return @applySetting(eventSetting, context)

    defaultSetting = @getTransportSetting(settingName)
    if defaultSetting?
      return @applySetting(defaultSetting, context)

    return @applySetting()


  applySetting: (setting, context) ->
    if not setting?
      return "No setting set"

    # Execute setting function
    if typeof setting is "function"
      return setting.call(context.receiver, context.event)

    # Return setting as string
    return setting
