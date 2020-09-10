lcov = require('gulp-lcov-to-html')
gulp = require('gulp')

gulp.task('lcov', function () {
    // grab the lcov files
    return gulp.src("coverage/lcov.info").pipe(lcov({name: "Optional Suite Name"})).pipe(gulp.dest("bin"))
});