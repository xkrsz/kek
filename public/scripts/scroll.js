$(document).ready(function(){
    $('#scroll').click(function (e) {
        $(".mdl-layout__content").animate({
            scrollTop: $('.row').next().offset().top
        }, 1000);
    });
});