$(document).ready(function(){
  var theOneInTheSide = $('#the-one-in-the-side');
  if (theOneInTheSide.length === 0) {
    $("form:not(.filter) :input:visible:enabled:first").focus();
  }
  $('#nav_btn').click(function() {
    $('.nav').toggle();
    $('.navigation').toggleClass('grey');
    $('#nav_btn i').toggleClass('icon-plus');
    $('#nav_btn i').toggleClass('icon-minus');
  });
});
