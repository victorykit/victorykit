$(document).ready(function() {
  $(".colorize").each(function() {
    var colors = $(this).data("colors").split(",").map(function(v) { return parseFloat(v); }),
        increasing = colors[0] < colors[2];

    $(this).find(".point").each(function() {
      var value = parseFloat($(this).text());

      var color = increasing ?
        ( value <= colors[1] ? "red" : ( value <= colors[2] ? "orange" : "green" ) ) :
        ( value >  colors[1] ? "red" : ( value >  colors[2] ? "orange" : "green" ) );

      $(this).css({ color: color });
    });
  });
});
