'use strict';

// Read in environment variables
require('dotenv').config();

// Require modules
const gulp = require('gulp');

// Require tasks
gulp.task('fractal:update', require('./gulp-tasks/fractal/update')());
gulp.task('fractal:start', require('./gulp-tasks/fractal/start')());

gulp.task('watch', function () {
    return gulp.watch(
        ['public/typo3conf/ext/*/Components/**/*'],
        gulp.series('fractal:update')
    );
});

// Define the default task
gulp.task('default', gulp.series('fractal:update', 'fractal:start', 'watch'));
