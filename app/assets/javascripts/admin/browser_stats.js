$(document).ready(function () {
  var plotStyle = { series: {lines: {show: true, fill: true}, points: {show: true, fill: true}}};

  $(".plot-container").each(function() {
    var container = $(this), queryUrl = container.data("query-url");
    $.get(queryUrl).success(function(response) {
      $.plot(container, response, $.extend({ xaxis: { mode: container.data("mode") }}, plotStyle));
    });
  });
});