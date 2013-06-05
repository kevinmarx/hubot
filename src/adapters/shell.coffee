Readline = require 'readline'

Robot         = require '../robot'
Adapter       = require '../adapter'
{TextMessage} = require '../message'
exec          = require('child_process').exec
async         = require 'async'

class Shell extends Adapter
  send: (envelope, strings...) ->
    unless process.platform is 'win32'
     for str in strings
      console.log "\x1b[01;32m#{str}\x1b[0m"
      strArr = str.split(/\n/g)
      ex = []
      speech = (says) ->
        return (callback) ->
          exec('say ' + says, () -> callback())

      for i in strArr by 1
        sayString = i
        ex.push speech(sayString)

      async.series(ex)
    else
      for str in strings
        console.log "#{str}"
        exec('say #{str}')
    @repl.prompt()

  reply: (envelope, strings...) ->
    strings = strings.map (s) -> "#{envelope.user.name}: #{s}"
    @send envelope, strings...

  run: ->
    self = @
    stdin = process.openStdin()
    stdout = process.stdout

    process.on 'uncaughtException', (err) =>
      @robot.logger.error err.stack

    @repl = Readline.createInterface stdin, stdout, null

    @repl.on 'close', =>
      stdin.destroy()
      @robot.shutdown()
      process.exit 0

    @repl.on 'line', (buffer) =>
      @repl.close() if buffer.toLowerCase() is 'exit'
      @repl.prompt()
      user = @robot.brain.userForId '1', name: 'Shell', room: 'Shell'
      @receive new TextMessage user, buffer, 'messageId'

    self.emit 'connected'

    @repl.setPrompt "#{@robot.name}> "
    @repl.prompt()

exports.use = (robot) ->
  new Shell robot
