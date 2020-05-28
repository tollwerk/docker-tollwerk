'use strict';

// Require modules
const gulp = require('gulp');
const postcss = require('gulp-postcss');
const postcssAtVariables = require('postcss-at-rules-variables');
const postcssSimplevars = require('postcss-simple-vars');
const postcssFor = require('postcss-for');
const postcssEach = require('postcss-each');
const postcssExtend = require('postcss-extend-rule');
const cssnano = require('cssnano');
const cssnext = require('postcss-cssnext');
const mixins = require('postcss-mixins');
const partialImport = require('postcss-partial-import');
const critical = require('postcss-critical-css');
const comments = require('postcss-discard-comments');
const insert = require('gulp-insert');
const nested = require('postcss-nested');
const assets = require('postcss-assets');
const glob = require('glob');
const fspath = require('path');
const sourcemaps = require('gulp-sourcemaps');
const concatFlatten = require('gulp-concat-flatten');
const rename = require('gulp-rename');
const filter = require('gulp-filter');
const concat = require('gulp-concat');
const { extractResourceExtensions } = require('../common');

let allExtensions = null;

/**
 * Create a task to compile the CSS of a particular extension
 *
 * @param {String} extension Extension key
 * @param {Object} params Parameters
 * @returns {Function} Task
 */
function compileExtensionCss(extension, params) {
    // Find a list of CSS resources to be imported for ALL compilations
    const extBaseDir = `${fspath.resolve(params.extDist, extension)}${fspath.sep}`;
    const autoIncludes = glob.sync(fspath.resolve(`${extBaseDir}/Configuration/Css/**/*.css`), { cwd: '/' });
    const task = (done) => {
        // Create a task
        gulp.src(
            [`${extension}/Resources/Private/Partials/**/*.css`, `!${extension}/Resources/Private/Partials/*/_*/**/*.css`],
            { cwd: params.extDist }
        )

        // Initialize sourcemaps
            .pipe(sourcemaps.init())

            // Flatten directories
            .pipe(concatFlatten(fspath.join(params.extDist, `${extension}/Resources/Private/Partials/*/*`), 'css', {}))

            // Import auto includes
            .pipe(insert.transform(function (contents, file) {
                autoIncludes.forEach((f) => {
                    contents = `@import "${fspath.relative(fspath.dirname(file.path), f)}";\n${contents}`;
                });
                return contents;
            }))

            // Run PostCSS processors
            .pipe(postcss([
                partialImport(),
                postcssAtVariables(),
                mixins(),
                postcssFor(),
                postcssEach(),
                nested(),
                postcssSimplevars(),
                comments(),
                postcssExtend(),
                cssnext({
                    autoprefixer: { browsers: ['IE >= 11'] },
                    features: { customProperties: { warnings: false } }
                }),
                assets({ loadPaths: [`${extBaseDir}Resources/Public/Fonts`] }),
                critical({
                    outputPath: `${extBaseDir}Resources/Public`,
                    outputDest: `${extension}-critical.min.css`,
                    preserve: true,
                    minify: true,
                }),
                cssnano({
                    autoprefixer: false,
                    zindex: false
                }),
            ]))

            // Rename to minified component resource
            .pipe(rename((path) => {
                const p = path.dirname.split(fspath.sep);
                path.basename = ((path.basename.substr(0, 1) === '_') ? '_' : '') + p.pop() + '.min';
                path.dirname = fspath.join('Resources/Public', p.pop());
            }))

            // Write atomic component CSS to extension destination directory
            .pipe(gulp.dest(extBaseDir))

            // Exclude internal CSS resources
            .pipe(filter(['**', '!**/_*.css']))

            // Concatenate all CSS resources
            .pipe(concat(`${extension}-default.min.css`))

            // // Write out sourcemaps
            .pipe(sourcemaps.write('.'))

            // Write monolithic CSS to destination directory
            .pipe(gulp.dest(`${extBaseDir}Resources/Public`));

        done();
    };

    Object.defineProperty(task, 'name', {
        value: `css:compile:${extension}`,
        configurable: true,
    });

    return task;
}

/**
 * Compile CSS files
 *
 * @param {String} file Changed file
 * @param {Object} params Parameters
 * @returns {*}
 */
function compileCss(file, params) {
    const tasks = extractResourceExtensions(file, params, '*/Resources/Private/Partials/*/*/{Styles.css,_Styles.css,Styles/*.css}')
        .map(ext => compileExtensionCss(ext, params));
    return tasks.length ? gulp.parallel(...tasks) : done => done();
}

module.exports = {
    task: params => compileCss(null, params),
    watch: params => gulp.watch([`${params.extDist}*/Configuration/Css/**/*.css`, `${params.extDist}*/Resources/Private/Partials/**/*.css`])
        .on('change', file => compileCss(file, params)()),
    dtp: 1
};
