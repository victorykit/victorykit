$(document).ready(function() {
  $('.chzn-select').chosen();
  
  $('#petition_location_us').click(function() {
    $('#location-states').removeClass('hidden');
    $('#location-countries').addClass('hidden');
  });

  $('#petition_location_non-us').click(function() {
    $('#location-states').addClass('hidden');
    $('#location-countries').removeClass('hidden');
  });

  $('#petition_location_all').click(function() {
    $('#location-states').addClass('hidden');
    $('#location-countries').addClass('hidden');
  });

  $('#petition_location_all').attr('checked', true);
});

