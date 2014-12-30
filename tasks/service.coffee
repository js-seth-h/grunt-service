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

  child_process = require('child_process')
  log = grunt.log 
  grunt.registerMultiTask 'service', 'background service', (arg1 = 'start') ->
    # console.log this
    self = this
    target = @target
    data = @data
    # data.core = data.core || 'spawn' # or exec
    options = @options
      failOnError : false
      # async : true
      stdio : 'pipe' 

    done = @async()


    killByPid = (callback)->
      if !fs.existsSync(data.pidFile)
        log.writeln "[Service] #{target} - pid file not exists"
        if data.failOnError
          return
        else
          return callback()

      pid = parseInt(fs.readFileSync data.pidFile)

      log.writeln "[Service] #{target}(pid=#{pid}) is killing "

      try
        process.kill pid
      catch err
        log.writeln "[Service] #{target}(pid=#{pid}) does not exists." 
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

      _spawned = ()-> callback()
      _closed = ()-> 
      if data.blocking
        _spawned = ()-> 
        _closed = ()-> callback() 


      if data.pidFile
        if fs.existsSync data.pidFile
          pid = parseInt(fs.readFileSync data.pidFile)
          if existProcess pid
            log.writeln "[Service] #{target}(pid=#{pid}) already exists." 
            return if data.failOnError
            return killByPid ()-> start(callback)

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

      # # console.log command, args , options
      # if data.core is 'exec'
      #   log.writeln 'exec -', command, args, options, arg1
      #   proc = child_process.exec command + ' ' + args , options
      # else 
      log.writeln 'spawn -', command, args, options, arg1
      proc = child_process.spawn command, args , options

      # console.log 'stdout', proc.stdout
 
      log.writeln "[Service] #{target} is starting."

      if proc.stdout
        proc.stdout.on 'data',  (d)->  log.writeln(d)
      if proc.stderr
        proc.stderr.on 'data',  (d)->  log.writeln(d)
        
      if proc
        log.writeln "Child PID = #{proc.pid}" 
        proc.on 'close', (code)->
          log.writeln 'child process exited with code ', arguments
          _closed()
        proc.on 'error', ()->
          log.writeln 'error', arguments
        proc.on 'exit', ()->
          log.writeln 'exit', arguments
        proc.on 'close', ()->
          log.writeln 'close', arguments
        proc.on 'disconnect', ()->
          log.writeln 'disconnect', arguments

      if data.generatePID and data.pidFile
        fs.writeFile(data.pidFile, proc.pid)

      if data.pidFile
        loopUntil ()-> 
          fs.existsSync data.pidFile
        , ()->
          pid = parseInt(fs.readFileSync data.pidFile) 
          log.writeln "[Service] #{target}(pid=#{pid}) is started." 
          _spawned()
      else
        log.writeln "[Service] #{target} is started." 
        _spawned()


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
          