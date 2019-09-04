(function (w, d) {
    'use strict';

    if (((typeof exports !== 'undefined') && exports.Observer) || w.Tollwerk.Observer) {
        return;
    }

    /**
     * Observer constructor
     *
     * @constructor
     */
    function Observer() {
        this.observed = [['[data-mutate-recursive]', this.process.bind(this)]];

        const checkNode = this.checkNode.bind(this);
        const observer = new MutationObserver(mutations => mutations
            .forEach(mutation => Array.prototype.slice.call(mutation.addedNodes)
                .filter(node => node.nodeType === 1).forEach(checkNode))
        );

        observer.observe(d.documentElement, { characterData: true, attributes: false, childList: true, subtree: true });
    }

    /**
     * Register a new selector / callback pair
     *
     * @param {String} selectors Selectors
     * @param {Function} callback Callback
     */
    Observer.prototype.register = function (selectors, callback) {
        this.observed.push([selectors, callback]);
    }

    /**
     * Check whether a newly created node should be processed
     *
     * @param {Element} node Node
     */
    Observer.prototype.checkNode = function (node) {
        this.observed.filter(observer => node.matches(observer[0])).forEach(observer => observer[1](node));
    }

    /**
     * Run all callbacks on a particular node and its children
     *
     * @param {Element} node Node
     */
    Observer.prototype.process = function (node) {
        if (node.nodeType === 1) {
            this.observed.forEach(observer => node.querySelectorAll(observer[0])
                .forEach(subnode => observer[1](subnode)));
        }
    }

    // Export as CommonJS module
    if (typeof exports !== 'undefined') {
        exports.Observer = new Observer();

        // Else create a global instance
    } else {
        w.Tollwerk.Observer = new Observer();
    }
})(typeof global !== 'undefined' ? global : window, document);
