function inviteToShareOnTwitter() {
  $('.fb_share.btn').hide();
  $('.fb_popup_btn').hide();
  $('.fb_share_message').hide();
  $('.tweet').show();
  $('.sharing-message').text("You shared on Facebook! How about Twitter?");
}

function initFacebookApp() {
  if (VK.facebook_sharing_type == "facebook_share" || VK.facebook_sharing_type == "facebook_widget") {
    var appId = $('meta[property="fb:app_id"]').attr('content');
    FB.init({
      appId: appId,
      status: true, // check login status
      cookie: true, // enable cookies to allow the server to access the session
      xfbml: true  // parse XFBML
    });
  }

  if (VK.facebook_sharing_type == "facebook_widget") {
    FB.Event.subscribe('auth.statusChange', function(checkAuthStatus) {
      if ((VK.fb_action_instance_id !== "") && (checkAuthStatus.status === "connected")) {
        FB.api(VK.fb_action_instance_id, 'get', function (response) {
          if (VK.fb_action_instance_id === response.id)  {
            inviteToShareOnTwitter();
          }
        });
      }
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
    openPopup();
    sendRequest();
    inviteToShareOnTwitter();
    $('.giantbox').hide();
  });

  function openPopup() {
    var sharer = "https://www.facebook.com/sharer/sharer.php?u=";
    var domain = location.href.replace(/\?.*/,"");
    var memberHash = VK.current_member_hash;
    var url = [sharer, domain, '?share_ref=', memberHash].join(''); 
    window.open(url , 'sharer', 'width=626,height=436');
  }

  function sendRequest() {
    $.ajax({
      url: VK.social_tracking_url,
      data: setUpParamsForSocialTracking('popup', '')
    });
  }
}

function bindFacebookWidgetButton() {
  $('.fb_widget_btn').click(performLoginAndOpenWidget);
  
  function performLoginAndOpenWidget() {
    FB.login(function (response) {
      (response.authResponse) && (openWidget());
    });
  }

  function openWidget() {
    var element = $('.facebook-share-widget');
    $('#thanksModal').modal('hide');
    $('#facebookFriendsModal').modal('toggle');
    $('#facebookFriendsModal').on('hide', drawMainArrow);
    var options = {
      base_path: '/widget',
      template:  { 'link': window.location.toString() }
    };
    new FacebookShareWidget(element, options);
  }
}

function drawJumpingArrow(element, closer) {
  $(element).nudgenudge({
    arrow: '/assets/limearrow.png',
    arrowWidth: 100,
    arrowHeight: 100,
    intensity: 'medium',  // the intensity of the nudge (low, medium, high)
    placement: 'left', // place on the left or the right of the target
    closeEvent: closer, // selector and event which triggers arrow hiding
    hideAfter: 0,  // hide after this many nudges, 0 = for the rest of eternity
    offsetX: 200, // adjust x position
    offsetY: -20 // adjust y position
  });
}

function drawMainArrow() {
  drawJumpingArrow('#thanks-for-signing-message .jumping_arrow', {"el": "#facebookFriendsModal", "event": "show"}); 
}

function drawModalAfterSigning() {
  var drawModalArrow = function() { drawJumpingArrow('#thanksModal .jumping_arrow', {"el": "#thanksModal", "event": "hide"}); };

  if (screen.width > 480 && $('#thanksModal').length) {
    $('#thanksModal').modal('toggle');
    drawModalArrow();
    $('#thanksModal').on('hide', drawMainArrow);
  } else {
    drawMainArrow();
  }
}

function initShowPetition() {
  preventWhitespaceOn('#signature_email');
  setupSocialTracking();

  $('form').on("submit", function (event) {
    if (!VK.signing_from_email) {
      var emailSuggestor = new EmailSuggestions();
      emailSuggestor.init();
      emailSuggestor.mailCheckSuggestions(event);
    }
    return event.go;
  });
}

function initSharePetition() {
  initTwitter();
  initFacebookApp();
  setupSocialTracking();
  setupShareFacebookButton();
  bindFacebookPopupButton();
  bindFacebookWidgetButton();
  drawModalAfterSigning();
}
