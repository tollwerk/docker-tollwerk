'use strict';

const gulp = require('gulp');
const clone = require('gulp-clone');
const brotli = require('gulp-brotli');
const gzip = require('gulp-gzip');
const es = require('event-stream');
const svgmin = require('gulp-svgmin');
const rename = require('gulp-rename');
const cheerio = require('gulp-cheerio');
const fspath = require('path');
const fs = require('fs');
const { extractResourceExtensions } = require('../common');
const crypto = require('crypto');
const plugins = [
// {cleanupAttrs					: true}, // cleanup attributes from newlines, trailing, and repeating spaces
// {removeDoctype					: true}, // remove doctype declaration
// {removeXMLProcInst				: true}, // remove XML processing instructions
// {removeComments					: true}, // remove comments
// {removeMetadata					: true}, // remove <metadata>
    { removeTitle: false }, // remove <title>
    { removeDesc: false }, // remove <desc>
// {removeUselessDefs				: true}, // remove elements of <defs> without id
// {removeXMLNS						: true}, // removes xmlns attribute (for inline svg, disabled by default)
// {removeEditorsNSData				: true}, // remove editors namespaces, elements, and attributes
// {removeEmptyAttrs				: true}, // remove empty attributes
// {removeHiddenElems				: true}, // remove hidden elements
// {removeEmptyText					: true}, // remove empty Text elements
// {removeEmptyContainers			: true}, // remove empty Container elements
    { removeViewBox: false }, // remove viewBox attribute when possible
// {cleanupEnableBackground			: true}, // remove or cleanup enable-background attribute when possible
// {minifyStyles					: false}, // minify <style> elements content with CSSO
// {convertStyleToAttrs				: false}, // convert styles into attributes
    { inlineStyles: false }, // Move <style> definitions to inline style attributes where possible
// {convertColors					: true}, // convert colors (from rgb() to #rrggbb, from #rrggbb to #rgb)
// {convertPathData					: true}, // convert Path data to relative or absolute (whichever is shorter), convert one segment to another, trim useless delimiters, smart rounding, and much more
// {convertTransform				: true}, // collapse multiple transforms into one, convert matrices to the short aliases, and much more
// {removeUnknownsAndDefaults		: true}, // remove unknown elements content and attributes, remove attrs with default values
// {removeNonInheritableGroupAttrs	: true}, // remove non-inheritable group's "presentation" attributes
// {removeUselessStrokeAndFill		: true}, // remove useless stroke and fill attrs
// {removeUnusedNS					: true}, // remove unused namespaces declaration
// {cleanupIDs						: true}, // remove unused and minify used IDs
// {cleanupNumericValues			: true}, // round numeric values to the fixed precision, remove default px units
// {cleanupListOfValues				: true}, // round numeric values in attributes that take a list of numbers (like viewBox or enable-background)
// {moveElemsAttrsToGroup			: true}, // move elements' attributes to their enclosing group
    { moveGroupAttrsToElems: true }, // move some group attributes to the contained elements
// {collapseGroups					: true}, // collapse useless groups
// {removeRasterImages				: true}, // remove raster images (disabled by default)
// {mergePaths						: true}, // merge multiple Paths into one
// {convertShapeToPath				: true}, // convert some basic shapes to <path>
// {sortAttrs						: true}, // sort element attributes for epic readability (disabled by default)
    { removeDimensions: true }, // remove width/height attributes if viewBox is present (opposite to removeViewBox, disable it first) (disabled by default)
// {removeAttrs						: true}, // remove attributes by pattern (disabled by default)
// {removeElementsByAttr			: true}, // remove arbitrary elements by ID or className (disabled by default)
// {addClassesToSVGElement			: true}, // add classnames to an outer <svg> element (disabled by default)
// {addAttributesToSVGElement		: true}, // adds attributes to an outer <svg> element (disabled by default)
// {removeStyleElement				: false}, // remove <style> elements (disabled by default)
// {removeScriptElement				: true}, // remove <script> elements (disabled by default)
];

// Prepare a meta data catalog
let meta;

/**
 * Create an MD5 checksum of a string
 *
 * @param {String} str String
 * @returns {string} Checksum
 */
function createChecksum(str) {
    return crypto
        .createHash('md5')
        .update('utf8')
        .digest('hex');
}

/**
 * Optimize an SVG graphic
 *
 * @param $ Cheerio instance
 * @param {Vinyl} file
 */
function optimizeSvg($, file) {
    const fileMeta = meta[file.basename] || {};
    const fileTitle = fileMeta.title || null;
    const fileDesc = fileMeta.desc || null;
    const checksum = createChecksum(file.contents);

    const $svg = $('svg');

    // Make the SVG graphic non-focusable (IE11 bug)
    $svg.attr('focusable', 'false');

    // Add or update the desc
    const $desc = $('desc');
    let descId = `svg-desc-${checksum}`;
    if ($desc.length) {
        const $descElement = $($desc[0]);
        descId = $descElement.attr('id') || descId;
        $descElement.attr('id', descId);
        $descElement.text(fileDesc || $descElement.text());

    } else if (fileDesc) {
        $svg.prepend($(`<desc id="${descId}">${fileDesc}</desc>`));
    } else {
        descId = null;
    }
    if (descId) {
        $($svg[0]).attr('aria-labelledby', descId);
    }

    // Add or update the title
    const $title = $('title');
    let titleId = `svg-title-${checksum}`;
    if ($title.length) {
        const $titleElement = $($title[0]);
        titleId = $titleElement.attr('id') || titleId;
        $titleElement.attr('id', titleId);
        $titleElement.text(fileTitle || $titleElement.text());

    } else if (fileTitle) {
        $svg.prepend($(`<title id="${titleId}">${fileTitle}</title>`));
    } else {
        titleId = null;
    }
    if (titleId) {
        $($svg[0]).attr('aria-labelledby', titleId);
    }
}

/**
 * Create a task to compile the SVG graphics of a particular extension
 *
 * @param {String} extension Extension key
 * @param {Object} params Parameters
 * @returns {Function} Task
 */
function compileExtensionSvg(extension, params) {
    const extBaseDir = fspath.join(fspath.resolve(params.extDist, extension), 'Resources');
    const metaJson = fspath.resolve(extBaseDir, 'Private/Graphics/Meta.json');
    meta = {};

    // If a meta file can be found
    try {
        if (fs.existsSync(metaJson)) {
            delete require.cache[metaJson];
            meta = require(metaJson);
        }
    } catch (err) {
        // Skip
    }

    const task = (done) => {
        const svg = gulp.src(`Private/Graphics/**/*.svg`, { base: extBaseDir, cwd: extBaseDir })
            .pipe(svgmin({ plugins }))
            .pipe(cheerio({ run: optimizeSvg, parserOptions: { lowerCaseAttributeNames: false } }))
            .pipe(rename((path) => {
                path.dirname = fspath.join('Public', path.dirname.substr(8));
            }));
        const brotlied = svg.pipe(clone()).pipe(brotli.compress({ extension: 'br', quality: 11 }));
        const gzipped = svg.pipe(clone()).pipe(gzip({ append: true, gzipOptions: { level: 9 } }));
        es.merge(svg, brotlied, gzipped).pipe(gulp.dest(extBaseDir));
        done();
    };

    Object.defineProperty(task, 'name', {
        value: `svg:compile:${extension}`,
        configurable: true,
    });

    return task;
}

/**
 * Compile SVG files
 *
 * @param {String} file Changed file
 * @param {Object} params Parameters
 * @returns {*}
 */
function compileSvg(file, params) {
    const tasks = extractResourceExtensions(file, params, `*/Resources/Private/Graphics/**/*.svg`)
        .map(ext => compileExtensionSvg(ext, params));
    return tasks.length ? gulp.parallel(...tasks) : done => done();
}

module.exports = {
    task: params => compileSvg(null, params),
    watch: params => gulp.watch([`${params.extDist}*/Resources/Private/Graphics/**/*.svg`, `${params.extDist}*/Resources/Private/Graphics/Meta.json`])
        .on('change', file => compileSvg(file, params)())
};
