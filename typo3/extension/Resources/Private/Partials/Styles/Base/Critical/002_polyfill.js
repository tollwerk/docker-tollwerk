// NodeList.forEach
if (window.NodeList && !NodeList.prototype.forEach) {
    NodeList.prototype.forEach = function (callback, thisArg) {
        thisArg = thisArg || window;
        for (var i = 0; i < this.length; i++) {
            callback.call(thisArg, this[i], i, this);
        }
    };
}

// Element.matches
if (!Element.prototype.matches) {
    Element.prototype.matches =
        Element.prototype.matchesSelector ||
        Element.prototype.mozMatchesSelector ||
        Element.prototype.msMatchesSelector ||
        Element.prototype.oMatchesSelector ||
        Element.prototype.webkitMatchesSelector ||
        (s => {
            const matches = (this.document || this.ownerDocument).querySelectorAll(s);
            let i = matches.length;
            while ((--i >= 0) && (matches.item(i) !== this)) {
            }
            return i > -1;
        });
}

// Element.closest
if (!Element.prototype.closest) {
    Element.prototype.closest = function (s) {
        let el = this;
        do {
            if (el.matches(s)) return el;
            el = el.parentElement || el.parentNode;
        } while (el !== null && el.nodeType === 1);
        return null;
    };
}

// String.format
if (!String.prototype.format) {
    String.prototype.format = function () {
        const args = arguments;
        return this.replace(/{(\d+)}/g, (match, number) => typeof args[number] != 'undefined' ? args[number] : match);
    };
}
