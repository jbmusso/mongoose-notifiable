EmailTransport = require("./transports/emailtransport")


buildEventsFields = (events) ->
  fields =
    notifications: {}

  # Dynamically build Mongoose "notifications" field and populate with each registered events
  for eventName, event of events
    fields.notifications[eventName] = {}

    # Set default behavior (enabled/disabled) for each event's actions
    for actionName, action of event
      # Set default value to false if default behavior is not set or is not boolean
      if event[actionName].default? and typeof event[actionName].default is "boolean"
        notifyByDefault = event[actionName].default
      else
        notifyByDefault = false

      # Attach event to Schema
      fields.notifications[eventName][actionName] =
        type: Boolean
        default: notifyByDefault

  return fields


module.exports = (schema, options) ->
  transports =
    email: new EmailTransport(options.transports.email, options.events)

  # Attach all possible events to Schema
  schema.add(buildEventsFields(options.events))

  """
  Register event to current model.
  Working, but potentially very dirty: events are registered every time a model is created. There might be room for performance improvements here. Maybe use methods/statics?
  """
  schema.post("init", ->
    for eventName, eventTransports of options.events
      registerEvent(this, eventName, eventTransports)
  )


  """
  Save current user notifications preferences, for each event and for each transport.
  """
  schema.method("setNotificationsOptions", (formData = {}, callback) ->
    for event, transporters of @notifications.toObject()
      for transport of transporters
        if @notifications[event]?
          @notifications[event][transport] = if formData[event]? then true else false

    @save(callback)
  )


  """
  Indicates if current user is interested in being notified of a given event by a given transport.

  @return {Boolean}
  """
  schema.method("wantsToBeNotifiedOf", (eventName, transport) ->
    return @notifications[eventName][transport]
  )


  """
  Notify another user that an event was triggered.

  For example: when 'this' (current user) sends 'user' a private message, user will emit the "privateMessageReceived" event.
  """
  schema.method("notify", (user, eventName, eventData = {}) ->
    event =
      name: eventName
      triggeredBy: this
      data: eventData

    user.emit(event.name, event)
  )


  registerEvent = (receiver, eventName, eventTransports) ->
    #TODO: loop through @notifications rather? Ie --> should we register a send email (or any other transport) event when the recipient didn't confirm their email address? Most likely not.
    # ... Maybe add a schema.model("acceptsTransport", (transportName) -> ...) method to model.
    for transportName, transport of eventTransports
      # Check if user wishes to be notified of this event
      if receiver.wantsToBeNotifiedOf(eventName, transportName)
        # Register event
        receiver.on(eventName, (event) ->
          # Call transport action
          transports[transportName].sendMessage(receiver, event, (err, status) ->
            # console.log err, status
          )
        )
