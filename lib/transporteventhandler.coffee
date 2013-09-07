"""
Handle an Event for a given Transport.

This class is responsible for 
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
