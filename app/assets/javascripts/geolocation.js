var geolocation = (function() {
  var ns = {};

  function hideAll() {
    $('#states, #countries').addClass('hidden');
  }

  function showStates() {
    $('#states').removeClass('hidden');
    $('#countries').addClass('hidden');
  }

  function showCountries() {
    $('#countries').removeClass('hidden');
    $('#states').addClass('hidden');
  }

  function updateStates() {
    var states =  $('#states .chzn-select').val();
    var val = $.map(states, function(s){ return 'us/'+s; }).join(',');
    $('#petition_location_us').val(val);
  }

  function updateCountries() {
    var countries = $('#countries .chzn-select').val();
    var val = $.map(countries, function(c){ return 'non-us/'+c; }).join(',');
    $('#petition_location_non-us').val(val);
  }

  ns.initialize = function() {
    $('.chzn-select').chosen();
    $('#petition_location_us').click(showStates);
    $('#petition_location_non-us').click(showCountries);
    $('#petition_location_all').click(hideAll);
    $('#states .chzn-select').chosen().change(updateStates);
    $('#countries .chzn-select').chosen().change(updateCountries);
  };

  return ns;
})();
