$(document).ready(function(){
    $("form:not(.filter) :input:visible:enabled:first").focus();
    $('#nav_btn').click(function() {
      $('.nav').toggle();
      $('.navigation .row').toggleClass('grey');
      $('#nav_btn i').toggleClass('icon-plus');
      $('#nav_btn i').toggleClass('icon-minus');
    });
});
