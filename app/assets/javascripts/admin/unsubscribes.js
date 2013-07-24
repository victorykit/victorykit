$(document).ready(function() {
  $("table.stats").each(function () {
    var table = $(this),
        url = table.data("stats");

    function loadData() {
      $.get(url, function(resp) {
        console.log(resp);
        table.find("#total").text(resp.total_lines);
        table.find("#seen").text(resp.seen_lines);
        table.find("#members").text(resp.members);
        table.find("#unsubscribes").text(resp.unsubscribes);
      });
    }

    setInterval(loadData, 1000);
    loadData();
  });      
});
