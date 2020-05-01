'use strict';

// Environment
const TITLE = process.env.TITLE || 'Unspecified';
const LABEL_COMPONENTS = process.env.LABEL_COMPONENTS || 'Patterns';

// Dependencies
const path = require('path');
const fractal = module.exports = require('@frctl/fractal').create();
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
fractal.set('project.title', TITLE);
fractal.components.set('label', LABEL_COMPONENTS);
fractal.components.set('path', path.join(__dirname, 'fractal', 'components'));
fractal.docs.set('path', path.join(__dirname, 'fractal', 'docs'));
fractal.web.set('static.path', path.join(__dirname, 'public'));
fractal.web.set('builder.dest', path.join(__dirname, 'fractal', 'build'));

// Configure the documentation: Add the renderComponents handler
const hbs = require('@frctl/handlebars')({
    helpers: {
        componentList: function () {
            return renderComponents(fractal.components, Array.from(arguments).pop());
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
const TYPO3_URL = process.env.TYPO3_URL || null;
if (TYPO3_URL) {
    const typo3 = require('fractal-typo3');
    typo3.configure('public', TYPO3_URL, theme);
    fractal.components.engine(typo3.engine);
    fractal.components.set('ext', '.t3s');
    fractal.cli.command('update-typo3 [typo3path]', typo3.update, {
        description: 'Update the components by extracting them from a TYPO3 instance (defaults to "public")'
    });
}

// If the Fractal instance is connected to a Tenon account
const TENON_API_KEY = process.env.TENON_API_KEY || null;
const TENON_PUBLIC_URL = process.env.TENON_PUBLIC_URL || null;
if (TENON_API_KEY && TENON_PUBLIC_URL) {
    require('fractal-tenon')(theme, {
        apiKey: TENON_API_KEY,
        publicUrl: TENON_PUBLIC_URL
    });
}

// Use the custom theme
fractal.web.theme(theme);
