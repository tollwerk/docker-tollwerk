'use strict';

const gulp = require('gulp');
const { combinePublicResourcesTask } = require('../common');

module.exports = {
    task: params => gulp.parallel(
        combinePublicResourcesTask('critical', 'css', params, false),
        combinePublicResourcesTask('default', 'css', params, true)
    ),
    watch: params => gulp.watch(`${params.extDist}*/Resources/Public/*-default.min.css`, gulp.series('css:combine')),
    dtp: 2
};
