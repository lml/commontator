window.Commontator = {};
Commontator._ = window._.noConflict();

Commontator.initMentions = function() {
    var textareas = document.querySelectorAll('.commontator .field textarea:not(.mentions-added)');
    textareas.forEach(function(textarea) {
        var $textarea = textarea;
        var $form = textarea.closest('form');
        var threadId = textarea.closest('.thread').getAttribute('id').match(/[\d]+/)[0];
        $textarea.classList.add('mentions-added');
        var $currentValue = $textarea.value;

        var tribute = new Tribute({
            values: function (text, callback) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '/commontator/threads/' + threadId + '/mentions.json?q=' + text, true);
                xhr.onload = function() {
                    if (xhr.status === 200) {
                        var responseData = JSON.parse(xhr.responseText);
                        var mentions = responseData.mentions.map(function(item) {
                            return {
                                key: item.id,
                                value: item.name
                            };
                        });
                        callback(mentions);
                    }
                };
                xhr.send();
            },
            allowSpaces: true,
            selectTemplate: function (item) {
                return '@' + item.original.value;
            }
        });

        tribute.attach($textarea);
        $textarea.value = $currentValue;

        $textarea.addEventListener('tribute-replaced', function () {
            var mentions = tribute.getSelectedItems();
            var inputs = $form.querySelectorAll('input[name="mentioned_ids[]"]');
            inputs.forEach(function(input) {
                input.remove();
            });
            mentions.forEach(function(mention) {
                var $input = document.createElement('input');
                $input.type = 'hidden';
                $input.name = 'mentioned_ids[]';
                $input.value = mention.key;
                $form.appendChild($input);
            });
        });
    });
};
