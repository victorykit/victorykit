$(document).ready(function() {
  var $email = $('#signature_email');
  var $hint = $("#hint");

  $('#ask-to-sign-modal').hide();
  if (!isPetitionSigned()) $('#ask-to-sign-modal').delay($('#ask-to-sign-modal-delay').val()).fadeIn(500);
  layoutPetitionSidebarAs(VK.signpetition_ask_vs_tell);

  new EmailSuggestions($email, $hint).initEmailSuggestions();

  initTwitter();

  $('#signature_email').change(function() {
    this.value = this.value.replace(/ /g, '');
  });

});

jQuery(function(){

  initFacebook();

  if (isPetitionSigned()) {
    displayForPetitionSigned();
  }

  $('#petition_description').wysihtml5();
  
  initTabIndexes();
});

function EmailSuggestions($email, $hint) {
  
  var self = this;

  this.initEmailSuggestions = function() {
    $('.suggested_email').live("click",function() {
      $email.val($(this).html());
      $hint.css('display', 'none');
      return false;
    });

    $('form').on("submit", function(event) {
      self.mailCheckSuggestions(event);
      return event.go;
    });    
  }

  this.mailCheckSuggestions = function(event) {
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
}

function layoutPetitionSidebarAs(ask_or_tell) {
  if ('ask' === ask_or_tell) {
    $('#signature-form').hide();
    $('#ask-to-sign').show();
  }
  else {
    $('#signature-form').show();
    $('#ask-to-sign').hide();
  };
}

function initTwitter() {
  $('.tweet').hide();

  !function(d,s,id) {
    var js,fjs=d.getElementsByTagName(s)[0];
    if(!d.getElementById(id)) {
      js=d.createElement(s);
      js.id=id;js.src="//platform.twitter.com/widgets.js";
      fjs.parentNode.insertBefore(js,fjs);}
    }
    (document,"script","twitter-wjs");
}

function askToSignModalClickYes() {
  layoutPetitionSidebarAs("tell");
  $("#ask-to-sign-modal").hide();
}

function askToSignModalClickNo() {
  $("#ask-to-sign-modal").hide();
}

function isPetitionSigned(){
  var cookie = $.cookie('signed_petitions') || '';
  var petitionIds = cookie.split("|");
  var currentPetitionId = $('#petitionId').val();
  return ($.inArray(currentPetitionId, petitionIds) > -1);
}

function initFacebook() {
  // prevent jQuery from appending cache busting string to the end of the FeatureLoader URL
  var cache = jQuery.ajaxSettings.cache;
  jQuery.ajaxSettings.cache = true;
  // Load FeatureLoader asynchronously. Once loaded, we execute Facebook init

  jQuery.getScript('http://connect.facebook.net/en_US/all.js', function() {
    FB.init({status: true, cookie: true, xfbml: true});
  });
  // just Restore jQuery caching setting
  jQuery.ajaxSettings.cache = cache;

  jQuery.getScript('http://connect.facebook.net/en_US/all.js', function() {
    FB.Event.subscribe('edge.create', function(response) {
       $('.fb-like').hide();
       $('.tweet').show();
    })
  });  
}

function displayForPetitionSigned() {
  $('#thanks-for-signing-message').show();
  $('#signature-form').hide();
  $('#ask-to-sign').hide();
  $('#thanksModal').modal('toggle');
}

function initTabIndexes() {
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
}