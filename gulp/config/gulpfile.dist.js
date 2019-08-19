'use strict';

const gulp = require('gulp');
const fractal = require('./fractal');
const logger = fractal.cli.console;

gulp.task('fractal:start', function () {
    const server = fractal.web.server({
        sync: true
    });
    server.on('error', err => logger.error(err.message));
    return server.start().then(() => {
        logger.success(`Fractal server is now running at ${server.url}`);
    });
});
