/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable no-param-reassign */

'use strict';

// Read in environment variables
require('dotenv')
    .config();

// General setup
const projectKey = (process.env.PROJECT_KEY || 'unspecified').toLowerCase();
const providerExt = process.env.PROJECT_EXTENSION || `tw_${projectKey}`;
const dist = `./public/fileadmin/${projectKey}/`;
const extDist = './public/typo3conf/ext/';
const providerExtDist = `${extDist}${providerExt}/`;
const watchAll = [];
const defaultTasks = [{
    task: 'watch',
    priority: 999
}];
const params = {
    projectKey,
    providerExt,
    dist,
    extDist,
    providerExtDist
};

// Require modules
const gulp = require('gulp');
const glob = require('glob');

glob.sync('**/*.js', { cwd: './gulp-tasks' })
    .map(r => r.substr(0, r.length - 3))
    .forEach(r => {
        const taskName = r.replace('/', ':');
        const { task, watch, dtp } = require(`./gulp-tasks/${r}`);
        task && gulp.task(taskName, task(params));
        watch && watchAll.push(...watch(params));
        dtp && defaultTasks.push({
            task: taskName,
            priority: dtp
        });
    });

// Define the watch task
gulp.task('watch', () => watchAll.forEach(args => gulp.watch(args[0], gulp.series.apply(null, args[1]))));

// Define the default task
gulp.task('default', gulp.series(...defaultTasks.sort((a, b) => a.priority - b.priority)
    .map(tp => tp.task)));
