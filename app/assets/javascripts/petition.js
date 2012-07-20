function inviteToShareOnTwitter() {
  $('.fb_share.btn').hide();
  $('.fb_popup_btn').hide();
  $('.fb_share_message').hide();
  $('.tweet').show();
  $('.sharing-message').text("You shared on Facebook! How about Twitter?");
}

function initFacebookApp() {
  if (VK.is_facebook_sharing_enabled === "true") {
    FB.Event.subscribe('auth.statusChange', function(checkAuthStatus) {
      if ((VK.fb_action_instance_id !== "") && (checkAuthStatus.status === "connected")) {
        FB.api(VK.fb_action_instance_id, 'get', function (response) {
          if (VK.fb_action_instance_id === response.id)  {
            inviteToShareOnTwitter();
          }
        });
      }
    });

    FB.init({
      appId:$('meta[property="fb:app_id"]').attr("content"),
      status:true, // check login status
      cookie:true, // enable cookies to allow the server to access the session
      xfbml:true  // parse XFBML
    });
  }
}

function setUpParamsForSocialTracking(facebook_action, action_id) {
  var params = {petition_id: VK.petition_id, facebook_action: facebook_action};
  if (VK.signature_id !== "") {
    params = $.extend(params, {signature_id: VK.signature_id});
  }
  if (action_id !== "") {
    params = $.extend(params, {action_id: action_id});
  }

  return params;
}

function setupSocialTracking() {
  try {
    if (FB && FB.Event && FB.Event.subscribe) {
      FB.Event.subscribe('edge.create', function (targetUrl) {
        _gaq.push(['_trackSocial', 'facebook', 'like', targetUrl]);
        //Google doesn't export social event data yet, so we have to track social actions as events too
        _gaq.push(['_trackEvent', 'facebook', 'like', targetUrl]);
        $.ajax({
          url: VK.social_tracking_url,
          data: setUpParamsForSocialTracking('like', '')
        });
        inviteToShareOnTwitter();
      });
      FB.Event.subscribe('edge.remove', function (targetUrl) {
        _gaq.push(['_trackSocial', 'facebook', 'unlike', targetUrl]);
        _gaq.push(['_trackEvent', 'facebook', 'unlike', targetUrl]);
      });
    }
  } catch (e) {
  }
}

function submitFacebookAction() {
  FB.login(function (response) {
    if (response.authResponse) {
      FB.api(
        '/me/watchdognet:sign',
        'post',
        {
          petition: $('meta[property="og:url"]').attr("content")
        },
        function (response) {
          if (!response || response.error) {
            $('.fb_share_message').text("Please try again.");
          } else {
            $.ajax({
              url: VK.social_tracking_url,
              data: setUpParamsForSocialTracking('share', response.id)
            });
            inviteToShareOnTwitter();
          }
        }
      );
    } else {
      $('.fb_share_message').hide();
    }
  }, {scope: 'publish_actions'});
}

function setupShareFacebookButton() {
  var shareButton = $('.fb_share.btn');
  shareButton.click(function (event) {
    $('.fb_share_message').text("Connecting to Facebook...");
    $('.fb_share_message').show();
    submitFacebookAction();
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
  $(item).wysihtml5({"html": true, parserRules: wysihtml5ParserRules});
}

function preventWhitespaceOn(input) {
  $(input).change(function () {
    this.value = this.value.replace(/ /g, '');
  });
}

function EmailSuggestions() {
  var self = this;
  var $email = $('#signature_email');
  var $hint = $("#hint");

  this.init = function () {
    $('.suggested_email').live("click", function () {
      $email.val($(this).html());
      $hint.css('display', 'none');
      return false;
    });
  };

  this.mailCheckSuggestions = function (event) {
    $hint.css('display', 'none');
    $email.mailcheck({
      //annoyingly, mailcheck doesn't let you add to their default list of domains, so we have to duplicate them all here.
      domains:["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com",
        "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk",
        "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com", "q.com"],
      suggested:function (element, suggestion) {
        event.go = true;
        if (!$hint.html()) {
          var suggestionFragment = 'Did you mean <a href="#" id="suggested_email" class="suggested_email">' + suggestion.full + "</a>?" +
            "<br/>Click the '" + $("#sign_petition").val() + "' button again if your address is correct";
          $hint.html(suggestionFragment).fadeIn(150);
          event.go = false;
        }
      }
    });
  };
}

function initTwitter() {
  var js, fjs = document.getElementsByTagName("script")[0];
  if (!document.getElementById("twitter-wjs")) {
    js = document.createElement("script");
    js.id = "twitter-wjs";
    js.src = "//platform.twitter.com/widgets.js";
    fjs.parentNode.insertBefore(js, fjs);
  }
}

function bindFacebookPopupButton() {
  $('.fb_popup_btn').click(function() {
    var sharer = "https://www.facebook.com/sharer/sharer.php?u=";
    window.open(sharer + location.href + "?share_ref=" + VK.fb_tracking_hash, 'sharer', 'width=626,height=436');
    $.ajax({
      url: VK.social_tracking_url,
      data: setUpParamsForSocialTracking('popup', '')
    });
    inviteToShareOnTwitter();
  });
}

$(document).ready(function () {
  initTwitter();
  initTabIndexes();
  initFacebookApp();
  setupShareFacebookButton();
  setupSocialTracking();
  bindFacebookPopupButton();

  if (screen.width > 480) {
    $('#thanksModal').modal('toggle');
  }

  preventWhitespaceOn('#signature_email');
  applyRichTextEditorTo('#petition_description');

  $('form').on("submit", function (event) {
    if (!VK.signing_from_email) {
      var emailSuggestor = new EmailSuggestions();
      emailSuggestor.init();
      emailSuggestor.mailCheckSuggestions(event);
    }
    return event.go;
  });

  if ($('#email_subject').has('.additional_title').length) {
    $('#email_subject').show();
    $('#email_subject_link').hide();
  }

  $('#email_subject_link').click(function () {
    $('#email_subject').show();
    $('#email_subject input').focus();
    $('#email_subject_link').hide();
  });

  if ($('#facebook_title').has('.additional_title').length) {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  }

  $('#facebook_title_link').click(function () {
    $('#facebook_title').show();
    $('#facebook_title_link').hide();
  });
});
