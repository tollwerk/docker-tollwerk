'use strict';

const gulp = require('gulp');
const shortbread = require('shortbread').stream;
const vinyl = require('vinyl-file');
const template = require('gulp-template');
const filter = require('gulp-filter');
const glob = require('glob');
const rename = require('gulp-rename');

/**
 * Find and read a critical file
 *
 * @param {String} pattern Glob pattern
 * @return {File} Vinyl file
 */
function criticalGlob(pattern) {
    let criticalFile = null;
    for (let criticalPath of glob.sync(pattern)) {
        try {
            criticalFile = vinyl.readSync(criticalPath);
            break;
        } catch (e) {
            // Skip
        }
    }
    return criticalFile;
}

/**
 * Create a task to combine all public resources with a particular prefix and file extension
 *
 * @param {Object} params Parameters
 * @returns {Function} Task
 */
function compileCache(params) {
    return () => {
        let criticalCSS;
        let criticalJS;

        // Prepare a filter for template files
        const tmpl = filter(['**/*.t3s', '**/*.jst'], { restore: true });

        // Determine the critical CSS resource
        criticalCSS = criticalGlob(`${params.assetDist}css/${params.projectKey}-critical.min.*.css`);

        // Determine the critical JavaScript resource
        criticalJS = criticalGlob(`${params.assetDist}js/${params.projectKey}-critical.min.*.js`);

        // Source relevant resources (including templates)
        return gulp.src(
            [
                `${params.assetDist}js/*.min.*.js`,
                `${params.assetDist}css/*-default.min.*.css`,
                // `${extDist}tw_googleanalytics/Resources/Public/Js/tw_googleanalytics.min.js`,
                `${params.providerExtDist}Resources/Private/TypoScript/35_page_resources.t3s`,
                `${params.providerExtDist}Resources/Private/JavaScript/Resources.jst`
            ],
            { base: 'public' })

        // Rename resources (where necessary)
            .pipe(rename((path) => {
                switch (path.extname) {
                case '.t3s':
                    path.dirname = 'Configuration/TypoScript/Main/Page';
                    break;
                case '.jst':
                    path.basename = '100_resources';
                    path.dirname = 'Resources/Private/JavaScript/Serviceworker';
                    break;
                }
            }))

            // Compile shortbread fragments
            .pipe(shortbread([criticalJS, criticalCSS], null, null, {
                initial: `Resources/Private/Fragments/Initial.html`,
                subsequent: `Resources/Private/Fragments/Subsequent.html`,
                prefix: `/`,
            }))

            // Filter template resources
            .pipe(tmpl)

            // Run templating process
            .pipe(template({
                site: params.projectKey,
                providerExt: `/typo3conf/ext/${params.providerExt}/`,
            }, { interpolate: /\{\{(.+?)\}\}/g }))

            // Restore all resources
            .pipe(tmpl.restore)

            // Write out compiled resources
            .pipe(gulp.dest(params.providerExtDist));
    };
}

module.exports = {
    task: params => compileCache(params),
};
