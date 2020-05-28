'use strict';

const gulp = require('gulp');
const { combinePublicResourcesTask } = require('../common');

module.exports = {
    task: params => gulp.parallel(
        combinePublicResourcesTask('critical', 'js', params, true),
        combinePublicResourcesTask('default', 'js', params, true)
    ),
    watch: params => gulp.watch(`${params.extDist}*/Resources/Public/*-default.min.js`, gulp.series('js:combine')),
    dtp: 11
};
