module.exports = class EmailTransport
  @buildMessage: (options, payload) ->

    fill = (option) =>
      if option?
        if typeof option is "function"
          message =
            sender: payload.sender
            receiver: this
            body: payload.message
          return option(message, payload)
        return option
      return "No option set"

    message =
      from: options.from
      to: "<#{@email.address}>"
      subject: fill(options.subject)
      text: fill(options.body.text)
      html: fill(options.body.html)

    @sendEmail(message, (err, status) ->)
