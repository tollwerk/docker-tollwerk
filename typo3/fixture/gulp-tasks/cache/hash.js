'use strict';

const gulp = require('gulp');
const hash = require('gulp-hash-filename');

module.exports = {
    task: params => {
        return () => gulp.src(
            ['js/*.min.js', 'css/*.min.css'],
            {
                cwd: params.assetDist,
                base: params.assetDist
            })
            .pipe(hash({ format: '{name}.{hash:8}{ext}' }))
            .pipe(gulp.dest(params.assetDist));
    }
};
