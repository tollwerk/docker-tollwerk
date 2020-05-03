'use strict';

const gulp = require('gulp');
const glob = require('glob');
const fspath = require('path');
const sourcemaps = require('gulp-sourcemaps');
const concat = require('gulp-concat');
const noop = require('gulp-noop');

/**
 * Extract the TYPO3 extension from a CSS file
 *
 * @param {String} file CSS file
 * @param {Object} params Parameters
 * @param {String} allGlob Glob pattern to match all relevant files
 * @returns {Array}
 */
function extractResourceExtensions(file, params, allGlob) {
    const extBaseDir = `${fspath.resolve(params.extDist)}${fspath.sep}`;

    // If a particular CSS file was given
    if (file) {
        const absFile = fspath.resolve(file);
        if (absFile.indexOf(extBaseDir) === 0) {
            return [absFile.substr(extBaseDir.length)
                .split(fspath.sep)
                .shift()];
        }

    }

    // Else: Return all TYPO3 extensions with CSS files
    return [...new Set(glob.sync(allGlob, { cwd: extBaseDir })
        .map(f => f.split('/')
            .shift()))];
}

/**
 * Create a task to combine all public resources with a particular prefix and file extension
 *
 * @param {String} prefix Prefix
 * @param {String} extension File extension
 * @param {Object} params Parameters
 * @param {Boolean} maps Render source maps
 * @returns {Function} Task
 */
function combinePublicResourcesTask(prefix, extension, params, maps) {
    const task = (done) => {
        gulp.src(`*/Resources/Public/*-${prefix}.min.${extension}`, { cwd: params.extDist })

        // Initialize sourcemaps
            .pipe(maps ? sourcemaps.init({ loadMaps: true }) : noop())

            // Concatenate all CSS resources
            .pipe(concat(`${params.projectKey}-${prefix}.min.${extension}`))

            // Write out sourcemaps
            .pipe(maps ? sourcemaps.write('.') : noop())

            // Write monolithic CSS to destination directory
            .pipe(gulp.dest(`${params.assetDist}${extension}`));

        done();
    };

    Object.defineProperty(task, 'name', {
        value: `${extension}:combine:${prefix}`,
        configurable: true,
    });

    return task;
}

module.exports = {
    extractResourceExtensions,
    combinePublicResourcesTask
};
