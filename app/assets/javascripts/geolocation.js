var geolocation = (function() {
  var ns = {};

  ns.initialize = function() {
    $('.chzn-select').chosen();
    $("#petition_location_type").change(updateLocationVisibility);

    $('#states .chzn-select').chosen().change(updateStates);
    $('#countries .chzn-select').chosen().change(updateCountries);
    rebuildSelections();
    updateLocationVisibility();
  };

  function hideAll() {
    $('#states, #countries').addClass('hidden');
    $('#location-details').val('');
  }

  function showStates() {
    $('#states').removeClass('hidden');
    $('#countries').addClass('hidden');
    updateStates();
  }

  function showCountries() {
    $('#countries').removeClass('hidden');
    $('#states').addClass('hidden');
    updateCountries();
  }

  function updateStates() { update('#states'); }
  function updateCountries() { update('#countries'); }

  function updateLocationVisibility() {
    var val = $("#petition_location_type").val();
    if      (val === 'us')     { showStates(); }
    else if (val === 'non-us') { showCountries(); }
    else                       { hideAll(); }
  }

  function update(selector) {
    var val = $(selector+' .chzn-select').val();
    $('#petition_location_details').val(val ? val.join(',') : '');
  }

  function rebuildSelections() {
    var loc = $('#petition_location_type').val();
    var div = {'us': '#states', 'non-us': '#countries'}[loc];
    if(!div) { return; }
    var sel = ' .chzn-select';
    var details = $('#petition_location_details').val().split(',');
    console.log("location details", details);
    $(details).each(function(i, e) {
      $(div+sel+' option[value="'+e+'"]').attr('selected', true);
      $(div+sel).trigger('liszt:updated');
    });
    $(div).removeClass('hidden');
  }

  return ns;
})();
