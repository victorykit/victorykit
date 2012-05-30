$(document).ready(function() {
	var domains = ['hotmail.com', 'gmail.com', 'aol.com'];
	var $email = $('#signature_email');
	var $hint = $("#hint");
	$email.blur(function() {
	  $hint.css('display', 'none'); // Hide the hint
	  $email.mailcheck({
	  	domains: domains,
	    suggested: function(element, suggestion) {
	       	if(!$hint.html()) {
	        var suggestion = "Did you mean <b>" + suggestion.full + "</b>?";              
	        $hint.html(suggestion).fadeIn(150);
	      }
	    }
	  });
	});
});

jQuery(function(){
	var cookie = $.cookie('signed_petitions') || '';
	var petitionIds = cookie.split("|");
	var currentPetitionId = $('#petitionId').val();
	if ($.inArray(currentPetitionId, petitionIds) > -1) {
    $('#thanks-for-signing-message').show();
    $('#sign-up-form').hide();
    $('#thanksModal').modal('toggle');
  }
  $('#petition_description').wysihtml5();

});