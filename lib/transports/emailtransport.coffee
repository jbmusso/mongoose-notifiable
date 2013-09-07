Transport = require("./transport")

module.exports = class EmailTransport extends Transport
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
