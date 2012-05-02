jQuery ->
  $('#petitions').dataTable
    sPaginationType: "full_numbers"
    bPaginate: false
    bFilter: false
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#petitions').data('source')
