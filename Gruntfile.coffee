 
module.exports = (grunt)->  


  grunt.loadTasks 'tasks'
  grunt.initConfig      
    service: 
      mkdir: 
        command: 'mkdir'
        args: ['<%= testDir %>']
         # shellCommand : 'set DEBUG=* && coffee app.coffee'
        # shellCommand : 'mkdir <%= testDir %>'
        options : 
          failOnError: false
          stdio : 'pipe'

    testDir: 'tasks' 


  # grunt.registerTask('default', 'concurrent:watch');
  grunt.registerTask 'default', 'service:mkdir'