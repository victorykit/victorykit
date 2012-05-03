jQuery ->
  $('#petitions').dataTable
    sPaginationType: "full_numbers"
    bFilter: false
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#petitions').data('source')
