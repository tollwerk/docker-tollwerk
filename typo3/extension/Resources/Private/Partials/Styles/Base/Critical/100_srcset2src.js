(function (w, d) {
    const removeAttribute = ('srcset' in d.createElement('img')) ? 'src' : 'srcset';
    w.Tollwerk.Observer.register('img[srcset][src]', img => img.removeAttribute(removeAttribute));
})(typeof global !== 'undefined' ? global : window, document);
