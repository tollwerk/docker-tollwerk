(function (w, d) {
    'use strict';

    // Polyfill classList support for IE11
    if (!('classList' in SVGElement.prototype)) {
        Object.defineProperty(SVGElement.prototype, 'classList', {
            get() {
                return {
                    contains: className => {
                        return this.className.baseVal.split(' ')
                            .indexOf(className) !== -1;
                    },
                    add: className => {
                        return this.setAttribute('class', this.getAttribute('class') + ' ' + className);
                    },
                    remove: className => {
                        const removedClass = this.getAttribute('class')
                            .replace(new RegExp('(\\s|^)' + className + '(\\s|$)', 'g'), '$2');
                        if (this.classList.contains(className)) {
                            this.setAttribute('class', removedClass);
                        }
                    }
                };
            }
        });
    }

    const docElementClassList = d.documentElement.classList;

    // JavaScript feature detection
    docElementClassList.remove('no-js');
    docElementClassList.add('has-js');

    // :focus-within detection
    try {
        d.querySelector(':focus-within');
        docElementClassList.add('has-focus-within');
    } catch (ignoredError) {
        docElementClassList.add('no-focus-within');
    }

    // touch detection
    d.addEventListener('touchstart', function touched() {
        docElementClassList.add('has-touch');
        d.removeEventListener('touchstart', touched, false);
    }, false);

})(typeof global !== 'undefined' ? global : this, document);


