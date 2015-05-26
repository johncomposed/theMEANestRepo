gulp = require('gulp')
clean = require('gulp-clean')
concat = require('gulp-concat')
nodemon = require('gulp-nodemon')
livereload = require('gulp-livereload')
minifyCss = require('gulp-minify-css')
uglify = require('gulp-uglify')
exec = require('child_process').exec
runCommand = (command) ->
  (cb) ->
    exec command, (err, stdout, stderr) ->
      console.log stdout
      console.log stderr
      cb err
      return
    return

# Directories
baseDirs = 
  app: './'
  dist: './dist/'
publicDirs = 
  _self: 'public/'
  js: 'public/js/'
  css: 'public/css/'
  img: 'public/img/'
bowerDir = baseDirs.app + 'bower_components/'
# Bower components first!
appFiles = 
  js: [
    bowerDir + '**/*.min.js'
    baseDirs.app + 'js/**/*.js'
  ]
  css: [
    bowerDir + '**/*.min.css'
    baseDirs.app + 'css/**/*.css'
  ]
  index: [ baseDirs.app + 'views/index.jade' ]
concatFilenames = 
  js: 'js.js'
  css: 'css.css'
startupScript = 'server.js'

sysDirs = [
  baseDirs.app + 'app/**/*.js'
  baseDirs.app + 'views/**/*.jade'
  baseDirs.app + 'node_modules/'
]


# Gulp Reload Etc Tasks
gulp.task 'startmongo', runCommand('mongod --dbpath ./db/')
gulp.task 'stopmongo', runCommand('mongo --eval "use admin; db.shutdownServer();"')
gulp.task 'nodemon', ->
  nodemon(
    script: baseDirs.app + startupScript
    ext: 'js'
    ignore: [baseDirs.app + 'public/', baseDirs.app + 'js/', baseDirs.app + 'css/']
  ).on 'restart', ->
    console.log 'Magic restarted'
    return
  return

gulp.task 'livereload', ['dev:concatjs', 'dev:concatcss'], ->
  gulp.src(appFiles.index).pipe livereload()

gulp.task 'watch', ->
  livereload.listen()
  gulp.watch([appFiles.js, appFiles.css, baseDirs.app + '**/*.jade'], 
  [ 'livereload' ]).on 'change', (event) ->
    console.log 'File ' + event.path + ' was ' + event.type + ', running tasks...'
    return
  return
  
  
# Gulp development tasks
gulp.task 'clean', ->
  gulp.src(baseDirs.dist, read: false).pipe clean()
gulp.task 'dev:concatjs', ->
  gulp.src(appFiles.js).pipe(concat(concatFilenames.js)).pipe gulp.dest(baseDirs.app + publicDirs.js)
gulp.task 'dev:concatcss', ->
  gulp.src(appFiles.css).pipe(concat(concatFilenames.css)).pipe gulp.dest(baseDirs.app + publicDirs.css)


# Gulp distribution tasks 
gulp.task 'dist:minifycss', ->
  gulp.src(baseDirs.app + publicDirs.css + concatFilenames.css).pipe(minifyCss()).pipe gulp.dest(baseDirs.dist + publicDirs.css)
gulp.task 'dist:minifyjs', ->
  gulp.src(baseDirs.app + publicDirs.js + concatFilenames.js).pipe(uglify()).pipe gulp.dest(baseDirs.dist + publicDirs.js)
gulp.task 'dist:copy', ->
  # server.js
  gulp.src(baseDirs.app + '/' + startupScript).pipe gulp.dest(baseDirs.dist)
  # sysDirs
  gulp.src(sysDirs, cwd: baseDirs.app + '**').pipe gulp.dest(baseDirs.dist)
  return

# Gulp main commands 
gulp.task 'default', [
  'dev:concatjs'
  'dev:concatcss'
  'nodemon'
  'startmongo'
  'watch'
]
gulp.task 'dist', [
  'dev:concatjs'
  'dev:concatcss'
  'dist:minifycss'
  'dist:minifyjs'
  'dist:copy'
]