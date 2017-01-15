$(function() {
    function isSufficientlyLargeScreen() {
        if (! window.matchMedia) {
            return false;
        }

        return window.matchMedia('(min-width: 600px)').matches;
    }

    $('#feedMenu').on('click', function(event) {
        event.stopImmediatePropagation();
        var $feedMenu = $('#feedMenu');
        if (isSufficientlyLargeScreen()) {
            $('#feedMenuMobile').hide();
            $feedMenu.dropdown('toggle');
        }
        else {
            $feedMenu.parent().removeClass('open');
            $("#feedMenuMobile").slideToggle("fast");
        }

        return false;
    });
});
