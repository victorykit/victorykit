jQuery(function() {
  return $('#petitions').dataTable({
    sPaginationType: "bootstrap",
    bFilter: false,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#petitions').data('source'),
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span5'p>>",
    aaSorting: [[1, "desc"]],
    aoColumnDefs: [
      {
        aTargets: [0],
        sCellType: "th"
      }
    ],
    aoColumns: [
      {
        asSorting: ["asc", "desc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }, {
        asSorting: ["desc", "asc"]
      }
    ]
  });
});
