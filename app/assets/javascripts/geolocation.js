var geolocation = (function() {
  var ns = {};

  ns.initialize = function() {
    $('.chzn-select').chosen();
    $('#petition_location_us').click(showStates);
    $('#petition_location_non-us').click(showCountries);
    $('#petition_location_all').click(hideAll);
    //$('.chzn-select').chosen().change( … )
  }

  function hideAll() {
    $(['#states', '#countries']).each(function(i, s) {
      $(s).addClass('hidden');
    });
  }

  function showStates() {
    $('#states').removeClass('hidden');
    $('#countries').addClass('hidden');
  }

  function showCountries() {
    $('#countries').removeClass('hidden');
    $('#states').addClass('hidden');
  }

  return ns;
})();
