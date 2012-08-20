function inviteToShareOnTwitter() {
  $('.fb_share.btn').hide();
  $('.fb_popup_btn.btn-primary').hide();
  $('.fb_request_btn').hide();
  $('.fb_share_message').hide();
  $('.tweet').show();
  $('.sharing-message').text("You shared on Facebook! How about Twitter?");
  //  Add this to get facebook button to change to twitter when fb is clicked
  //if ($('.img_plus_fb_ribbon').length) {
  //  $('.img_plus_fb_ribbon').addClass('tw');
  //}
  //if ($('.thanks_with_share_sidebar').length) {
  //  $('.share_box').addClass('tw');
  //}
  // $('.fb_popup_btn').hide();
  // $('.tw a').css('display', 'block');
}

function initFacebookApp() {
  if(['facebook_share', 'facebook_wall', 'facebook_request'].indexOf(VK.facebook_sharing_type) >= 0) {
    var appId = $('meta[property="fb:app_id"]').attr('content');
    FB.init({
      appId: appId,
      status: true, // check login status
      cookie: true, // enable cookies to allow the server to access the session
      xfbml: true,  // parse XFBML
      frictionless:true // for facebook request dialog
    });
  }

  if (VK.facebook_sharing_type == "facebook_wall") {
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

function setUpParamsForSocialTracking(facebook_action, action_id, request_id, request_to_ids) {
  var params = {petition_id: VK.petition_id, facebook_action: facebook_action};
  if (VK.signature_id !== "") {
    params = $.extend(params, {signature_id: VK.signature_id});
  }
  if (action_id !== "") {
    params = $.extend(params, {action_id: action_id});
  }
  if (request_id !== "") {
    params = $.extend(params, {request_id: request_id});
    params = $.extend(params, {friend_ids: request_to_ids});
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
          data: setUpParamsForSocialTracking('like', '', '', '')
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
              data: setUpParamsForSocialTracking('share', response.id, '', '')
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
      data: setUpParamsForSocialTracking('popup', '', '', '')
    });
  }

  $('.fb_popup_btn').click(function() {
    openPopup();
    sendRequest();
    inviteToShareOnTwitter();
    $('.giantbox').hide();
  });
}

function bindFacebookWidgetButton() {

  function openWidget() {
    var element = $('.facebook-share-widget');
    $('#thanksModal').modal('hide');
    $('#facebookFriendsModal').modal('toggle');
    var domain = location.href.replace(/\?.*/,"");
    var options = {
      base_path: '/widget',
      template:  { 'link': domain + '?wall=' + VK.current_member_hash }
    };
    if (VK.fbWallLoaded) { return; }
    var widget = new FacebookShareWidget(element, options);
    VK.fbWallLoaded = true;
    $('.facebook-share-widget .search-text').get(0).focus();
  }

  function performLoginAndOpenWidget() {
    FB.login(function (response) {
      if (response.authResponse) {
        openWidget();
       }
    }, {scope: 'publish_stream'});
  }

  $('.fb_widget_btn').click(performLoginAndOpenWidget);
}

function bindFacebookRequestButton() {

  function requestCallbackForSendRequest(response) {
    if(response && response.request) {
      $.ajax({
        url: VK.social_tracking_url,
        data: setUpParamsForSocialTracking('request', '', response.request, response.to)
      });
    }
      inviteToShareOnTwitter();
  }

  function sendRequestViaMultiFriendSelector() {
    FB.ui({method: 'apprequests',
      message: VK.petition_title
    }, requestCallbackForSendRequest);
  }

  $('.fb_request_btn').click(sendRequestViaMultiFriendSelector);
}


function drawModalAfterSigning() {
  if (screen.width > 480 && $('#thanksModal').length) {
    $('#thanksModal').modal('toggle');
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
  bindFacebookRequestButton();
  drawModalAfterSigning();
}
