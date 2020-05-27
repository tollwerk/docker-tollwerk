'use strict';

// Load environment variables
require('dotenv').config();

// Environment
const FRACTAL_TITLE = process.env.FRACTAL_TITLE || 'Unspecified';
const FRACTAL_COMPONENTS_LABEL = process.env.FRACTAL_COMPONENTS_LABEL || 'Patterns';

// Dependencies
const path = require('path');
const fractal = module.exports = require('@frctl/fractal')
    .create();
const ComponentCollection = require('@frctl/fractal/src/api/components/collection');
const ComponentSource = require('@frctl/fractal/src/api/components/source');
const theme = require('@frctl/mandelbrot')({ 'nav': ['docs', 'components'] });

/**
 * Render an component source overview
 *
 * @param {ComponentSource} componentSource Component source
 * @param {Array} options Options
 * @return {string} Component source overview (HTML)
 */
function renderComponents(componentSource, options) {
    let ret = '';
    let sub = '';
    // Run though all components of this component source
    for (let component of componentSource) {
        // Descend into subcollections
        if (component instanceof ComponentCollection) {
            sub = renderComponents(component.items(), options);
            if (sub.length) {
                ret += '<li><strong>' + component.label + '</strong>' + sub + '</li>';
            }
        } else if (!component.isHidden) {
            if (component.variants && (component.variants().size > 1)) {
                sub = renderComponents(component.variants(), options);
                ret += '<li><strong>' + component.label + '</strong>' + sub + '</li>';
            } else {
                ret += '<li>' + options.fn(Object.assign(component.toJSON(), { status: component.status })) + '</li>';
            }
        }
    }
    return ret.length ? ('<ul>' + ret + '</ul>') : '';
}

// Base settings
fractal.set('project.title', FRACTAL_TITLE);
fractal.components.set('label', FRACTAL_COMPONENTS_LABEL);
fractal.components.set('path', 'components');
fractal.docs.set('path', 'docs');
fractal.web.set('static.path', path.join(__dirname, 'public'));
// fractal.web.set('builder.dest', 'build');

// Configure the documentation: Add the renderComponents handler
const hbs = require('@frctl/handlebars')({
    helpers: {
        componentList: function () {
            return renderComponents(fractal.components, Array.from(arguments)
                .pop());
        }
    }
});
fractal.docs.engine(hbs);

// Add a TBD status
fractal.components.set('statuses', Object.assign({
    tbd: {
        label: 'TBD',
        description: 'Planned but not yet started. Go ahead! :)',
        color: '#CCCCCC'
    }
}, fractal.components.get('statuses')));

// If the Fractal instance is connected to a TYPO3 instance
const PROJECT_URL = process.env.PROJECT_URL || 'http://localhost';
if (PROJECT_URL) {
    const logger = require('fancy-log');
    logger.log = logger.bind(logger);
    const typo3 = require('fractal-typo3');
    typo3.configure(PROJECT_URL, !!parseInt(process.env.FRACTAL_DEVELOPMENT, 10), theme, logger);
    fractal.components.engine(typo3.engine);
    fractal.components.set('ext', '.t3s');
    fractal.cli.command('update-typo3', typo3.update, {
        description: 'Update the components by extracting them from a TYPO3 instance (defaults to "public")'
    });
}

// If the Fractal instance is connected to a Tenon account
const FRACTAL_TENON_API_KEY = process.env.FRACTAL_TENON_API_KEY || null;
const FRACTAL_PUBLIC_URL = process.env.FRACTAL_PUBLIC_URL || null;
if (FRACTAL_TENON_API_KEY && FRACTAL_PUBLIC_URL) {
    require('fractal-tenon')(theme, {
        apiKey: FRACTAL_TENON_API_KEY,
        publicUrl: FRACTAL_PUBLIC_URL
    });
}

// Use the custom theme
fractal.web.theme(theme);
