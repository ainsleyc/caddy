module.exports = function (grunt) {

  grunt.initConfig({
    pkg: '<json:package.json>',
    cafemocha: {
      src: [ 'test/**/*.coffee' ],
      options: {
        timeout: 3000,
        ignoreLeaks: false,
        ui: 'bdd',
        reporter: 'spec',
        compilers: 'coffee:coffee-script',
        globals: [
        ]
      }
    },
    watch: {
      files: [ 'Gruntfile.js', 'lib/**/*.coffee', 'test/**/*.coffee' ],
      tasks: [ 'coffee', 'cafemocha' ]
    },
    coffee: {
      compile: {
        files: {
          'dist/caddy.js': 'lib/caddy.coffee'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-cafe-mocha');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  grunt.registerTask('default', [ 'coffee', 'cafemocha', 'watch' ]);

};
