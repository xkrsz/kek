$(document).ready(function(){
    $('#scroll').click(function (e) {
        $(".mdl-layout__content").animate({
            scrollTop: $('.layout').offset().top
        }, 1000);
        $(this).fadeOut();
    });
});