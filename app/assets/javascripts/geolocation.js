var geolocation = (function() {
  var ns = {};

  function hideAll() {
    $('#states, #countries').addClass('hidden');
    $('#location-details').val('');
  }

  function showStates() {
    $('#states').removeClass('hidden');
    $('#countries').addClass('hidden');
  }

  function showCountries() {
    $('#countries').removeClass('hidden');
    $('#states').addClass('hidden');
  }

  function update(selector) {
    var val = $(selector+' .chzn-select').val();
    $('#location-details').val(val ? val.join(',') : '');
  }

  function updateStates() { update('#states'); }
  function updateCountries() { update('#countries'); }

  function rebuildSelections() {
    var loc = $('#location-options input[checked="checked"]').val();
    var div = {'us': '#states', 'non-us': '#countries'}[loc];
    if(!div) { return; }
    var sel = ' .chzn-select';
    var details = $('#location-details').val().split(',');
    $(details).each(function(i, e) {
      $(div+sel+' option[value="'+e+'"]').attr('selected', true);
      $(div+sel).trigger('liszt:updated');
    });
    $(div).removeClass('hidden');
  }

  ns.initialize = function() {
    $('.chzn-select').chosen();
    $('#petition_location_type_us').click(showStates);
    $('#petition_location_type_non-us').click(showCountries);
    $('#petition_location_type_all').click(hideAll);
    $('#states .chzn-select').chosen().change(updateStates);
    $('#countries .chzn-select').chosen().change(updateCountries);
    rebuildSelections();
  };

  return ns;
})();
