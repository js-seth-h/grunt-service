# grunt-service

> start/stop/restart service( = background process), support kill by pidfile 

## Purpose

[grunt-shell][sh] and [grunt-shell-spawn][sp] has some obstacle in my experience. 
I want to start/restart my server code for developemnt.
But, these plugins remove readability of debug message, and can't kill process in window(my development environment)


## Features

* options pass to childprocess.spawn
* so, this supports full option of childprocess.spawn include `stdio: ignore`, `stdio: inherit`, `stdio: ['ignore','pipe','pipe']` and `stdio: [0, 1,2 ]`  
* kill process by `PID file`


 
## Getting Started

If you haven't used [grunt][] before, be sure to check out the [Getting Started][] guide, as it explains how to create a [gruntfile][Getting Started] as well as install and use grunt plugins. Once you're familiar with that process, install this plugin with this command:

```bash
$ npm install --save-dev grunt-service
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-service');
```

*Tip: the [load-grunt-tasks](https://github.com/sindresorhus/load-grunt-tasks) module makes it easier to load multiple grunt tasks.*

[grunt]: http://gruntjs.com
[Getting Started]: https://github.com/gruntjs/grunt/wiki/Getting-started


## Examples


### Support `debug` module & PID File

```coffee

  grunt.initConfig   
    fastWatch:   
      mess: 
        dirs : '.'
        ignore:  watchTarget.messIgnore
        tasks: ["service:server:restart"] # or tasks['service:server:stop']
    service: 
      server: 
        shellCommand : 'set DEBUG=* && coffee app.coffee'
        pidFile : (process.env.TMPDIR || process.env.TEMP) + '/app.pid'  
        options :
          stdio : 'inherit'

  grunt.loadNpmTasks('grunt-spawn');
  grunt.loadNpmTasks('grunt-fast-watch'); 
  grunt.registerTask('default', ['service:server']);
  
```

Run server and show it debug log without changes( inclulde coloring and date).

I make & use [grunt-fast-watch][grunt-fast-watch] instead `grunt-watch` several reason. see also [grunt-fast-watch][grunt-fast-watch].

[grunt-fast-watch]:  https://www.npmjs.org/package/grunt-fast-watch


### Create a folder named `test`.

```js
grunt.initConfig({
	spawn: {
		makeDir: {
			shellCommand: 'mkdir test'
      option: {
        failOnError: false
      }
		}
	}
});
```
Making direcity.
Evne if fail mkdir (because of already exists), No Error occured.

     
### Spwan direclty 

```js
grunt.initConfig({
  testDir: 'test3',
	spawn: {
		direct: {
      command: 'mkdir'
      args: ['<%= testDir %>']
		}
	}
});
```


#### Run command and display the output

Output a directory listing in your Terminal.

```js
grunt.initConfig({
	shell: {
		dirListing: {
			command: 'ls'
		}
	}
});
``` 
 


## options
	
options will pass to 1childprocess.spawn` without changes

so, please refer [Node.js API Document](http://www.nodejs.org/api/child_process.html#child_process_child_process_spawn_command_args_options)

-  default value of `stdio` is 'pipe', it means grunt can read stdio.

And some added option are as follows:


### failOnError
 
Default: `false`
Type: `Boolean`

If false, exit code of command is ignored.
if true, exit code 0 mean success( continue next task ) otherwise grunt show error and stop

### async

Default: `true`
Type: `Boolean`

If true, the next task is to continue after the end of the command.
If false, the next task is to continue without blocking.


## License

MIT


[sh]: https://github.com/sindresorhus/grunt-shell 
[sp]: https://github.com/cri5ti/grunt-shell-spawn