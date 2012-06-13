$(document).ready(function() {
  isPetitionSigned() ? displayForPetitionSigned() : displayForPetitionNotSigned();
  preventWhitespaceOn('#signature_email');
  applyRichTextEditorTo('#petition_description');
  if(!VK.signing_from_email)
    new EmailSuggestions().init();
  initTwitter();
  initFacebook();
  initTabIndexes();
});

function isPetitionSigned(){
  var cookie = $.cookie('signed_petitions') || '';
  var petitionIds = cookie.split("|");
  var currentPetitionId = $('#petitionId').val();
  return ($.inArray(currentPetitionId, petitionIds) > -1);
}

function displayForPetitionSigned() {
  $('#thanks-for-signing-message').show();
  $('#signature-form').hide();
  $('#ask-to-sign').hide();
  $('#thanksModal').modal('toggle');
}

function displayForPetitionNotSigned() {
  layoutPetitionSidebarAs(VK.signpetition_ask_vs_tell);
  $('#ask-to-sign-modal').delay($('#ask-to-sign-modal-delay').val()).fadeIn(500);
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
}

function applyRichTextEditorTo(item) {
  $(item).wysihtml5();
}

function preventWhitespaceOn(input) {
  $(input).change(function() { this.value = this.value.replace(/ /g, ''); });
}

function EmailSuggestions() {
  var self = this;
  var $email = $('#signature_email');
  var $hint = $("#hint");

  this.init = function() {
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
      //annoyingly, mailcheck doesn't let you add to their default list of domains, so we have to duplicate them all here.
      domains: ["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com",
                "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk",
                "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com", "q.com"],
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
       $('.tweet').show();
    })
  });
}

function initTwitter() {
  !function(d,s,id) {
    var js,fjs=d.getElementsByTagName(s)[0];
    if(!d.getElementById(id)) {
      js=d.createElement(s);
      js.id=id;js.src="//platform.twitter.com/widgets.js";
      fjs.parentNode.insertBefore(js,fjs);}
    }
    (document,"script","twitter-wjs");
}
