"""
Handle an Event for a given Transport.

For a given Transport (= for a given way of being notified), this class is responsible for:
  1) retrieving custom eventSettings (if available) or defaultTransportSetting (if available)
  2) passing these settings to the Transport so the notification can be generated and delivered to its destination.
"""
module.exports = class TransportEventHandler
  constructor: (@transport, @eventSettings) ->


  getSetting: (settingName) ->
    return @eventSettings.options?[settingName]


  """
  Attempt to grab setting defined at the event level, if any.

  Falls back to global transport-level setting if event-level setting is missing.
  """
  resolveSetting: (settingName, context) ->
    eventSetting = @getSetting(settingName)
    if eventSetting?
      return @applySetting(eventSetting, context)

    transportSetting = @transport.getDefaultSetting(settingName)
    if transportSetting?
      return @applySetting(transportSetting, context)

    return @applySetting()


  """
  Handle settings, checks if it's a function or a string

  @return {String}
  """
  applySetting: (setting, context) ->
    if not setting?
      return "No setting set"

    # Setting is a function, execute it...
    if typeof setting is "function"
      return setting.call(context.receiver, context.event)

    # Setting is a string, just return the string
    return setting
