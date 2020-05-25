CKEDITOR.plugins.add('codeTag', {
    icons: 'code',
    init: function (editor) {
        var codeStyle = new CKEDITOR.style({ element: 'code' });
        editor.addCommand('wrapCode', new CKEDITOR.styleCommand(codeStyle));
        editor.ui.addButton('Code', {
            label: 'Wrap code',
            command: 'wrapCode',
            toolbar: 'insert'
        });
    }
});
