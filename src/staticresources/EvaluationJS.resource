(function ($) {
    openModalDialog = function (dialogId, titleString, formId) {
        var $element = $(document.getElementById(dialogId));
        if ($element.dialog("isOpen")!==true) {
            $element.dialog({
                title: titleString,
                modal: true,
                width: 800,
                resizable: false,
                minHeight: 0,
                dialogClass: 'modalDialog',
                closeOnEscape:false,
                zIndex: 9, // so that datepickers appear on top of the dialogs
                position: {
                    my: "center top",
                    at: "center top"
                },
                open: function () {
                    // Don't allow "background" to be scrollable when dialogs
                    // are open.
                    $("body").css("overflow", "hidden");
                }
            }).parent().appendTo($(document.getElementById(formId)));
            $element.parent().find('a.ui-dialog-titlebar-close').remove();
        }
    };
    closeModalDialog = function (dialogId) {
        var $element = $(document.getElementById(dialogId));
        $element.dialog('destroy');
        // Allow "background" to be scrollable when dialogs are closed.
        $("body").css("overflow", "auto");
    };
    afterSave = function (dialogId, keepDialogOpen, functionToOpenNewDialog) {
        var $dialog = $(document.getElementById(dialogId));
        if ($dialog.find('.errorMsg').length == 0) {
            closeModalDialog(dialogId);
            if (keepDialogOpen) {
                (functionToOpenNewDialog)();
            }
        }
    }
    removeSpacer = function () {
        $(document).ready(function () {
            // Disable all spacer elements' parents, we do this here because we can't
            // select parents via CSS
            $("img[src$='spacer.gif']").parent().css("display", "none")
        });
    }
    removeSpacer();
}) (jQuery.noConflict());
