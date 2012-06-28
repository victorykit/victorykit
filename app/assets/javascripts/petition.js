$(document).ready(function() {
  initTwitter();
  //loadFacebookApi();
  initTabIndexes();
  setupShareFacebookButton();
  // will show it only if it`s in the DOM

  if(screen.width > 480) {
    $('#thanksModal').modal('toggle');
  }

  preventWhitespaceOn('#signature_email');
  applyRichTextEditorTo('#petition_description');

  $('form').on("submit", function(event) {
    if(!VK.signing_from_email) {
      var emailSuggestor = new EmailSuggestions();
      emailSuggestor.init();
      emailSuggestor.mailCheckSuggestions(event);
    }
    return event.go;
  });

  if($('#email_subject').has('.additional_title').length) {
    $('#email_subject').show();
    $('#email_subject_link').hide();
  }

  $('#email_subject_link').click(function() {
    $('#email_subject').show();
    $('#email_subject_link').hide();
  });

  if($('#facebook_title').has('.additional_title').length) {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  }

  $('#facebook_title_link').click(function() {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  });


});

function loadFacebookApi() {
  // Load the SDK Asynchronously
  (function(d){
    var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "//connect.facebook.net/en_US/all.js";
    d.getElementsByTagName('head')[0].appendChild(js);
  }(document));
}

function setupShareFacebookButton() {
  var shareButton = $('.fb_share.btn')
  shareButton.click(function(event) {
    shareButton.hide();
    $('.tweet').show();
    $('#thanks-for-signing-message .share').text("Spread the word, share on Twitter!");
    submitFacebookAction();
  });

}

function submitFacebookAction() {
  FB.init({
    appId      : $('meta[property="fb:app_id"]').attr("content"),
    status     : true, // check login status
    cookie     : true, // enable cookies to allow the server to access the session
    xfbml      : true  // parse XFBML
  });

  FB.login(function(response) {
    if (response.authResponse) {
      console.log('Welcome!  Fetching your information.... ');
      FB.api(
        '/me/watchdognet:sign',
        'post',
        {
          petition: $('meta[property="og:url"]').attr("content")
        },
        function(response) {
          if (!response || response.error) {
            console.log('Error occured');
            console.log(response.error);
          } else {
            console.log('Sign was successful! Action ID: ' + response.id);
          }
        });
    } else {
      console.log('User cancelled login or did not fully authorize.');
    }}, {scope: 'publish_actions'});
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
