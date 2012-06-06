$(document).ready(function() {
	var $email = $('#signature_email');
	var $hint = $("#hint");

	$('.suggested_email').live("click",function() {
        $email.val($(this).html());
        $hint.css('display', 'none');
        return false;
    });

	$('form').on("submit", function(event) {
		mailCheckSuggestions(event);
		return event.go;
    });

	function mailCheckSuggestions(event) {
		$hint.css('display', 'none');
	  	$email.mailcheck({
	    suggested: function(element, suggestion) {
	    	event.go = true;
	       	if(!$hint.html()) {
	        	var suggestion = 'Did you mean <a href="#" id="suggested_email" class="suggested_email">' + suggestion.full + "</a>?";
	     	   	$hint.html(suggestion).fadeIn(150);
      			event.go = false;
	      }
	    }
	  });
	}

	layoutPetitionSidebarAs(VK.signpetition_ask_vs_tell);

    $('#signature_email').change(function() {
        this.value = this.value.replace(/ /g, '');
    });
});

function layoutPetitionSidebarAs(ask_or_tell)
{
	if ('ask' === ask_or_tell) {
		$('#signature-form').hide();
		$('#ask-to-sign').show();
	}
	else {
		$('#signature-form').show();
		$('#ask-to-sign').hide();
	};
}

jQuery(function(){
  // prevent jQuery from appending cache busting string to the end of the FeatureLoader URL
  var cache = jQuery.ajaxSettings.cache;
  jQuery.ajaxSettings.cache = true;
  // Load FeatureLoader asynchronously. Once loaded, we execute Facebook init

  jQuery.getScript('http://connect.facebook.net/en_US/all.js', function() {
    FB.init({status: true, cookie: true, xfbml: true});
  });
  // just Restore jQuery caching setting
  jQuery.ajaxSettings.cache = cache;
});

jQuery(function(){
	var cookie = $.cookie('signed_petitions') || '';
	var petitionIds = cookie.split("|");
	var currentPetitionId = $('#petitionId').val();
	if ($.inArray(currentPetitionId, petitionIds) > -1) {
    $('#thanks-for-signing-message').show();
    $('#signature-form').hide();
    $('#ask-to-sign').hide();
    $('#thanksModal').modal('toggle');
  }
  $('#petition_description').wysihtml5();
  $('#petition_title').attr('tabIndex', '1');
  $('iframe').attr('tabIndex', '2');
  if ($('#petition_to_send').length) {
    $('#petition_to_send').attr('tabIndex', '3');
    $('#petition_submit').attr('tabIndex', '4');
  }
  else {
    $('#petition_submit').attr('tabIndex', '3');
  }

  $('#petition_title').attr('tabIndex', '1');
  $('iframe').attr('tabIndex', '2');
  if ($('#petition_to_send').length) {
    $('#petition_to_send').attr('tabIndex', '3');
    $('#petition_submit').attr('tabIndex', '4');
  }
  else {
    $('#petition_submit').attr('tabIndex', '3');
  }

});
