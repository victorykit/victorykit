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

$(document).ready(function() {
  $('.chzn-select').chosen();
  $('#petition_location_us').click(showStates);
  $('#petition_location_non-us').click(showCountries);
  $('#petition_location_all').click(hideAll).attr('checked', true);  
});
