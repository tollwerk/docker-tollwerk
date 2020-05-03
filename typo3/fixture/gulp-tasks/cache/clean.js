'use strict';

const gulp = require('gulp');
const clean = require('gulp-clean');

module.exports = {
    task: params => {
        return () => gulp.src(
            [`js/*.min.*.js`, 'css/*.min.*.css'],
            {
                cwd: params.assetDist,
                read: false
            })
            .pipe(clean());
    }
};
