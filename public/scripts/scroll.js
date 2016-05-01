$(document).ready(function(){
    $('#scroll').click(function (e) {
        $(".mdl-layout__content").animate({
            scrollTop: $('.second-row').offset().top
        }, 1000);
    });
});