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


loopUntil = (fnEndOk, done)->
  loopId = setInterval ()->
    if true is fnEndOk()
      clearInterval loopId
      done()
  , 200


module.exports = ( grunt ) ->

  spawn = require('child_process').spawn
  log = grunt.log 
  grunt.registerMultiTask 'service', 'background service', (arg1 = 'start') ->
    # console.log this
    self = this
    target = @target
    data = @data
    options = @options
      failOnError : false
      # async : true
      stdio : 'pipe'
    # console.log 'opt - ', arg1

    done = @async()


    killByPid = (callback)->
      return log.writeln "[Service] #{target} - pid file not exists" unless  fs.existsSync data.pidFile
      pid = parseInt(fs.readFileSync data.pidFile)

      log.writeln "[Service] #{target}(pid=#{pid}) is killing "

      try
        process.kill pid
      catch err
        log.writeln "[Service] #{target}(pid=#{pid}) already exists." 
        return callback()


      loopUntil ()-> 
        not existProcess(pid)
      , ()->
        log.writeln "[Service] #{target}(pid=#{pid}) is killed." 
        callback()
  

      # idKiller = setInterval ()->
      #   try
      #     process.kill pid
      #   catch err
      #     log.writeln "[Service] #{target}(pid=#{pid}) is killed." 
      #     clearInterval idKiller
      #     callback()
      # , 200


    start = (callback)-> 
      if data.pidFile
        if fs.existsSync data.pidFile
          pid = parseInt(fs.readFileSync data.pidFile)
          if existProcess pid
            log.writeln "[Service] #{target}(pid=#{pid}) already exists." 
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
      # grunt.log.writelnln command, args, options, arg1
      proc = spawn command, args , options


      # console.log 'stdout', proc.stdout
 
      log.writeln "[Service] #{target} is starting."

      if proc.stdout
        proc.stdout.on 'data',  (d)->  log.writeln(d)
      if proc.stderr
        proc.stderr.on 'data',  (d)->  log.writeln(d)


      if data.pidFile
        loopUntil ()-> 
          fs.existsSync data.pidFile
        , ()->
          pid = parseInt(fs.readFileSync data.pidFile) 
          log.writeln "[Service] #{target}(pid=#{pid}) is started." 
          callback()
      else
        callback()


      # if options.async
      #   done = self.async()
      #   proc.on 'exit', (code)->
      #     return done() if not options.failOnError
      #     return done() if code is 0 

      #     done new Error "Finished with error #{code}"
  
    switch arg1
      when "stop"
        killByPid ()-> done()
      when "restart" 
        killByPid ()-> 
          start ()->
            done() 
      when "start"    
        start ()->
          done() 
          