###
(c) js.seth.h@gmail.com
MIT License
###


fs = require 'fs' 

log = undefined

existProcess = (pid)-> 
  try
    process.kill pid, 0
  catch err
    return false
  return true


kill= (pid)->
  try
    process.kill pid
  catch err
    log.write "Process(pid=#{pid}) may be not exists." 
 

module.exports = ( grunt ) ->

  spawn = require('child_process').spawn
  log = grunt.log 
  grunt.registerMultiTask 'service', 'background service', (arg1 = 'start') ->
    # console.log this
    target = @target
    data = @data
    options = @options
      failOnError : false
      async : true
      stdio : 'pipe'
    # console.log 'opt - ', arg1

    pid = parseInt(fs.readFileSync data.pidFile) 
    
    return kill(pid) if arg1 is 'stop'
    kill(pid) if arg1 is 'restart' 

    if arg1 is 'start'
      if existProcess pid
        log.write "Process(pid=#{pid}) already exists." 
        return


    command = data.command  
    # console.log data.command , data.args

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