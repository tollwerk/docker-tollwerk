'use strict';

const gulp = require('gulp');
const logger = require('fancy-log');

module.exports = {
    task: params => {
        return function () {
            logger.info('Recompiling components ...');
            return require('../../fractal.config')
                .cli
                ._execFromString('update-typo3');
        };
    },
    watch: params => gulp.watch('public/typo3conf/ext/*/Components/**/*', gulp.series('fractal:update')),
    dtp: 30
};
