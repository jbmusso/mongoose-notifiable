module.exports = class EmailTransport
  constructor: (@settings, @events) ->
    console.log "EmailTransport constructor"
    console.log @settings
    console.log @events


  """
  Get default transport setting, or custom event setting
  """
  resolveSetting: (settingName, context) ->
    eventSetting = @getEventSetting(settingName, context)
    if eventSetting?
      return applySetting(eventSetting, context)

    defaultSetting = @getTransportSetting(settingName)
    if defaultSetting?
      return applySetting(defaultSetting, context)

    return applySetting()


  sendMessage: (receiver, event) ->
    context =
      receiver: receiver
      event: event

    message =
      from: @resolveSetting("from", context)
      to: "<#{receiver.email.address}>"
      subject: @resolveSetting("subject", context)
      text: @resolveSetting("text", context)
      html: @resolveSetting("html", context)

    receiver.sendEmail(message, (err, status) ->)


  getEventSetting: (settingName, context) ->
    return @events[context.event.name].email.options?[settingName]


  getTransportSetting: (settingName) ->
    return @settings[settingName]


applySetting = (setting, context) ->
  if not setting?
    return "No setting set"

  # Execute setting function
  if typeof setting is "function"
    return setting.call(context.receiver, context.event)

  # Return setting as string
  return setting
