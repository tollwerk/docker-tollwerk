'use strict';

// Require modules
const gulp = require('gulp');
const fspath = require('path');
const sourcemaps = require('gulp-sourcemaps');
const concatFlatten = require('gulp-concat-flatten');
const pump = require('pump');
const typescript = require('gulp-typescript');
const rename = require('gulp-rename');
const filter = require('gulp-filter');
const concat = require('gulp-concat');
const uglify = require('gulp-uglify');
const sort = require('gulp-sort');
const { extractResourceExtensions } = require('../common');

let allExtensions = null;

/**
 * Create a task to compile the CSS of a particular extension
 *
 * @param {String} extension Extension key
 * @param {Object} params Parameters
 * @returns {Function} Task
 */
function compileExtensionJs(extension, params) {
    const extBaseDir = `${fspath.resolve(params.extDist, extension)}${fspath.sep}`;
    const task = (done) => {
        const critical = filter(['**/*.critical.min.js', '!**/_*.critical.min.js'], { restore: true });
        const noncritical = filter(['**/*.default.min.js', '!**/_*.default.min.js'], { restore: true });
        pump([
            gulp.src(
                [`${extension}/Resources/Private/Partials/**/*.js`, `!${extension}/Resources/Private/Partials/*/_*/**/*.js`],
                { cwd: params.extDist }
            ),
            sourcemaps.init(),
            sort(),
            concatFlatten(fspath.join(params.extDist, `${extension}/Resources/Private/Partials/*/*`), 'js', {}),
            rename((path) => { // Rename to minified file
                const p = path.dirname.split(fspath.sep);
                path.basename = ((path.basename.substr(0, 1) === '_') ? '_' : '') + p.pop() + ((path.basename.toLocaleLowerCase() === 'critical') ? '.critical' : '.default') + '.min';
                path.dirname = fspath.join('Resources/Public', p.pop());
            }),
            typescript({
                target: 'ES5',
                allowJs: true
            }),
            uglify(),
            gulp.dest(`${extBaseDir}`), // Write single JavaScript files to extension destination directory
            critical,
            concat(`${extension}-critical.min.js`),
            sourcemaps.write('.'), // Write out sourcemaps
            gulp.dest(`${extBaseDir}Resources/Public`), // Write combined JavaScript file to destination directory
            critical.restore,
            noncritical,
            concat(`${extension}-default.min.js`),
            sourcemaps.write('.'), // Write out sourcemaps
            gulp.dest(`${extBaseDir}Resources/Public`), // Write combined JavaScript file to destination directory
        ], done);
    };

    Object.defineProperty(task, 'name', {
        value: `js:compile:${extension}`,
        configurable: true,
    });

    return task;
}

/**
 * Compile JavaScript files
 *
 * @param {String} file Changed file
 * @param {Object} params Parameters
 * @returns {*}
 */
function compileJs(file, params) {
    const tasks = extractResourceExtensions(file, params, '*/Resources/Private/Partials/*/*/{Script.js,_Script.js,Script/*.js,Critical.js,_Critical.js,Critical/*.js}')
        .map(ext => compileExtensionJs(ext, params));
    return tasks.length ? gulp.parallel(...tasks) : done => done();
}

module.exports = {
    task: params => compileJs(null, params),
    watch: params => gulp.watch(`${params.extDist}*/Resources/Private/Partials/**/*.js`)
        .on('change', file => compileJs(file, params)()),
    dtp: 10
};
