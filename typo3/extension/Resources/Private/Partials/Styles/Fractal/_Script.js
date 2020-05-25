function copyToClipboard() {
    const cssField = document.getElementById('copy');
    if (cssField) {
        cssField.value = cssField.value.trim().split("\n").map(function (s) {
            return s.trim();
        }).join("\n");
        cssField.select();
        document.execCommand('copy');
    }
}
