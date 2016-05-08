$(document)
.ajaxStart(function(){
    $(".ajaxSpinner").addClass('active');
})
.ajaxStop(function(){
    $(".ajaxSpinner").removeClass('active');
});