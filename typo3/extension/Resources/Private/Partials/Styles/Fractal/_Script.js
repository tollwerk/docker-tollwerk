/* eslint no-unused-vars: ["error", { "varsIgnorePattern": "copyToClipboard" }] */
function copyToClipboard() {
    const cssField = document.getElementById('copy');
    if (cssField) {
        cssField.value = cssField.value.trim()
            .split('\n')
            .map((s) => s.trim())
            .join('\n');
        cssField.select();
        document.execCommand('copy');
    }
}
