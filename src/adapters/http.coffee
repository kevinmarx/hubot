Robot = require '../robot'
Server = require('http')
Events = require('events')

class Shell extends Robot
  eventEmitter = new Events.EventEmitter

  send: (user, strings...) ->
    strings.join("\n")
    eventEmitter.emit("botReply", str);

  reply: (user, strings...) ->
    for str in strings
      @send user, "#{user.name}: #{str}"

  onRequest: (request, response) =>
    request.setEncoding('utf8')
    request.on 'data', (content) =>
      content.toString().split("\n").forEach (line) =>
        return if line.length is 0
        @receive new Robot.TextMessage @user, line
      response.writeHead 200, {'Content-Type': 'text/plain'}

    eventEmitter.once 'botReply', (botResponse) =>
      response.end botResponse


  run: ->
    console.log "Hubot: the Shell."

    user = @userForId('1', {name: "Shell"})

    server = Server.createServer(@onRequest)

    server.listen 8124
    console.log 'Server running at http://localhost:8124/'

    process.stdin.resume()
    process.stdin.on 'data', (txt) =>
      console.log txt.toString()
      txt.toString().split("\n").forEach (line) =>
        return if line.length is 0
        @receive new Robot.TextMessage user, line

    setTimeout =>
      user   = @userForId('1', {name: "Shell"})
    , 3000



module.exports = Shell
