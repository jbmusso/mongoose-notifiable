Transport = require("./transport")

module.exports = class EmailTransport extends Transport
  buildMessage: (receiver, context) ->
    handler = @getEventHandler(context.event)

    message =
      from: handler.resolveSetting("from", context)
      to: "<#{receiver.email.address}>"
      subject: handler.resolveSetting("subject", context)
      text: handler.resolveSetting("text", context)
      html: handler.resolveSetting("html", context)

    return message


  sendMessage: (receiver, event, callback) ->
    context =
      receiver: receiver
      event: event

    message = @buildMessage(receiver, context)

    receiver.sendEmail(message, (err, status) ->
      callback(err, status)
    )
