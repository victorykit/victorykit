$(document).ready(function() {
  initTwitter();
  initFacebook();
  initTabIndexes();
  // will show it only if it`s in the DOM
  $('#thanksModal').modal('toggle');
  preventWhitespaceOn('#signature_email');
  applyRichTextEditorTo('#petition_description');

  $('form').on("submit", function(event) {
    if(!VK.signing_from_email) {
      var emailSuggestor = new EmailSuggestions();
      emailSuggestor.init();
      emailSuggestor.mailCheckSuggestions(event);
    }
    petition_id = $('.petition_id').text().trim();
    if(!(event.go === false) && (petition_id === "6")) {
      submitFacebookAction();
      return false;
    }
    return event.go;
  });
});

function initFacebook() {
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '335522893179500',
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });
  };
  // Load the SDK Asynchronously
  (function(d){
    var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "//connect.facebook.net/en_US/all.js";
    d.getElementsByTagName('head')[0].appendChild(js);
  }(document));
}


function submitFacebookAction() {
  console.log("HERE!!!!");
  FB.login();
  console.log(FB.getLoginStatus());
  FB.api(
    '/me/watchdognet:sign',
    'post',
    {
      petition: $('.petition_url').text()
    },
    function(response) {
      if (!response || response.error) {
        console.log('Error occured');
        console.log(response.error);
      } else {
        console.log('Sign was successful! Action ID: ' + response.id);
      }
    });
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
          var suggestion = 'Did you mean <a href="#" id="suggested_email" class="suggested_email">' + suggestion.full + "</a>?" +
              "<br/>Click the '" + $("#sign_petition").val() + "' button again if your address is correct";
          $hint.html(suggestion).fadeIn(150);
          event.go = false;
        }
      }
    });
  }
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
