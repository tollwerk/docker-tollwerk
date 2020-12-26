/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable import/no-unresolved */
/* eslint-disable no-param-reassign */

'use strict';

// Read in environment variables
require('dotenv')
    .config();

// Override Project URL
process.env.PROJECT_URL = 'http://localhost';

// General setup
const projectKey = (process.env.PROJECT_KEY || 'unspecified').toLowerCase();
const providerExt = process.env.PROJECT_EXTENSION || `tw_${projectKey}`;
const dist = `./public/fileadmin/${projectKey}/`;
const extDist = './public/typo3conf/ext/';
const providerExtDist = `${extDist}${providerExt}/`;
const assetDist = './public/typo3temp/assets/';
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
    providerExtDist,
    assetDist
};

// Require modules
const gulp = require('gulp');
const glob = require('glob');

glob.sync('**/*.js', { cwd: './gulp-tasks' })
    .map(r => r.substr(0, r.length - 3))
    .forEach(r => {
        const taskName = r.replace('/', ':');
        const {
            task,
            watch,
            dtp
        } = require(`./gulp-tasks/${r}`);
        task && gulp.task(taskName, task(params));
        watch && watchAll.push(watch);
        dtp && defaultTasks.push({
            task: taskName,
            priority: dtp
        });
    });

// Define the watch task
gulp.task('watch', () => watchAll.forEach(watch => watch(params)));

const sortedTasks = defaultTasks.sort((a, b) => a.priority - b.priority);

// Define the default task
gulp.task('default', gulp.series(...sortedTasks.map(tp => tp.task)));

// Define the build task
gulp.task('build', gulp.series(...sortedTasks.filter(tp => tp.priority < 100)
    .map(tp => tp.task)));
