###
(c) js.seth.h@gmail.com
MIT License
###
module.exports = ( grunt ) ->

  spawn = require('child_process').spawn

  grunt.registerMultiTask 'service', 'background service', (arg1) ->
    # console.log this
    target = @target
    data = @data
    options = @options
      failOnError : true
      async : true
      stdio : 'pipe'
    log = grunt.log
    # console.log 'opt - ', options 

    command = data.command  
    console.log data.command , data.args

    if data.shellCommand?
      shellCommand = data.shellCommand  
      if process.platform is "win32"
        command = "cmd.exe"
        args = ["/s", "/c", shellCommand.replace(/\//g, "\\") ]
        options.windowsVerbatimArguments = true
      else
        command = "/bin/sh"
        args = [ "-c", shellCommand ]
    else
      args = data.args

    # console.log command, args , opt
    # grunt.log.writeln command, args, options, arg1
    proc = spawn command, args , options

    # console.log 'stdout', proc.stdout

    if proc.stdout
      proc.stdout.on 'data',  (d)->  log.write(d)
    if proc.stderr
      proc.stderr.on 'data',  (d)->  log.write(d)

    if options.async
      done = @async()
      proc.on 'exit', (code)->
        return done() if not options.failOnError
        return done() if code is 0 

        done new Error "Finished with error #{code}"