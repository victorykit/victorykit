function changeSidebar() {
  $('.swap').click(function () {
    $('#thanks-for-signing-message').html('' +
      '<div class="share sidebar_plea">' +
        'Really?' +
        '<br /><br />' +
        'A small click can make a huge difference.' +
      '</div>' +
      '<div class="btn btn-primary share fb_f_share facebook_popup" id="the-one-in-the-side"></div>');
  });
}

function randomInt(range) {
  return Math.floor(Math.random() * range);
}

function modalFbImageRotator () {
  var imgList = [
    "fbmodal_1.png",
    "fbmodal_2.png",
    "fbmodal_3.png",
    "fbmodal_4.png",
    "fbmodal_5.png",
    "fbmodal_6.png",
    "fbmodal_7.png",
    "fbmodal_8.png",
    "fbmodal_9.png",
    "fbmodal_10.png",
    "fbmodal_11.png",
    "fbmodal_12.png",
    "fbmodal_13.png",
    "fbmodal_14.png",
    "fbmodal_15.png",
    "fbmodal_16.png",
    "fbmodal_17.png",
    "fbmodal_18.png",
    "fbmodal_19.png",
    "fbmodal_20.png",
    "fbmodal_21.png",
    "fbmodal_22.png",
    "fbmodal_23.png",
    "fbmodal_24.png",
    "fbmodal_25.png",
    "fbmodal_26.png",
    "fbmodal_27.png",
    "fbmodal_28.png",
    "fbmodal_29.png",
    "fbmodal_30.png"
  ];
  var textList = [
    "<b>Mike G</b> from <b>Mississippi</b> has shared.",
    "<b>Chetan C</b> from <b>Washington</b> has shared.",
    "<b>Eric S</b> from <b>Michigan</b> has shared.",
    "<b>Ines L</b> from <b>Portugal</b> has shared.",
    "<b>Emilie R</b> from <b>Washington</b> has shared.",
    "<b>Monica R</b> from <b>Florida</b> has shared.",
    "<b>Gerard P</b> from <b>Maryland</b> has shared.",
    "<b>Aaron M</b> from <b>UK</b> has shared.",
    "<b>Ashley R</b> from <b>Nevada</b> has shared.",
    "<b>Zack B</b> from <b>Michigan</b> has shared.",
    "<b>Kate B</b> from <b>California</b> has shared.",
    "<b>Subhrajit B</b> from <b>Pennsylvania</b> has shared.",
    "<b>Rutger M</b> from <b>Netherlands</b> has shared.",
    "<b>Sarah G</b> from <b>Ohio</b> has shared.",
    "<b>Jacob M</b> from <b>Sweden</b> has shared.",
    "<b>Siah M</b> from <b>New York</b> has shared.",
    "<b>Alex A</b> from <b>California</b> has shared.",
    "<b>Renae H</b> from <b>Utah</b> has shared.",
    "<b>Benjamin S</b> from <b>Pennsylvania</b> has shared.",
    "<b>Arthur V</b> from <b>Connecticut</b> has shared.",
    "<b>Noah H</b> from <b>New York</b> has shared.",
    "<b>Caroline D</b> from <b>Texas</b> has shared.",
    "<b>Beth S</b> from <b>Massachusetts</b> has shared.",
    "<b>Beth C</b> from <b>Michigan</b> has shared.",
    "<b>Peter V</b> from <b>New York</b> has shared.",
    "<b>Nico D</b> from <b>UK</b> has shared.",
    "<b>Sarah D</b> from <b>Alabama</b> has shared.",
    "<b>Melissa P</b> from <b>Ohio</b> has shared.",
    "<b>Angie H</b> from <b>Washington</b> has shared.",
    "<b>Cassie R</b> from <b>Georgia</b> has shared."
  ];

  var arrayOption = randomInt(imgList.length),
      fbHolder = $('.holder'),
      fbImage = $('.fb_image'),
      fbText = $('.fb_text');

  var status = {};

  function firstFbText(callback){
    var myid = Math.random();
    status[myid] = fbHolder.length;
    return function() {
      if (--status[myid] === 0) {
        return callback();
      }
    };
  }

  function slideFbImage(afterdone) {
    fbHolder.animate({opacity: '0', paddingTop:'+=60'}, {complete: firstFbText(afterdone)});
  }
  function revealFbImage(afterdone) {
    fbHolder.css('padding-top', 'inherit');
    fbHolder.animate({opacity: '1', paddingTop:'+=60'}, {complete: firstFbText(afterdone)});
  }

  function randomTimeInterval() {
    return Math.floor(Math.random() * 6000) + 4000;
  }

  function swapImage() {
    slideFbImage(function() {
      arrayOption = (arrayOption + 1) % imgList.length;
      fbImage.html("<img src=\"/assets/" + imgList[arrayOption] + "\" />");
      fbText.html(textList[arrayOption]);

      revealFbImage(function(){
        setTimeout(swapImage, randomTimeInterval());
      });
    });
  }
  setTimeout( function() {
      swapImage();
      $('.fb_image_holder').animate({height: '230'});
    }, randomTimeInterval() / 4);
}

function inviteToShareOnTwitter() {
  return;
}

function trackFacebookStatus(facebookStatus) {
  $.ajax({
    type: 'post',
    url: VK.social_tracking_url,
    data: {facebook_action: "status", facebook_status: facebookStatus.status}
  });
}

function initFacebookApp() {
  var appId = $('meta[property="fb:app_id"]').attr('content');
  FB.init({
    appId: appId,
    status: true, // check login status
    cookie: true, // enable cookies to allow the server to access the session
    xfbml: true,  // parse XFBML
    frictionless: true // for facebook request dialog
  });

  if (FB.getLoginStatus) { FB.getLoginStatus(trackFacebookStatus); }
  if (VK.facebook_sharing_type == "facebook_wall") {
    FB.Event.subscribe('auth.statusChange', function (facebookStatus) {
      if (VK.fb_action_instance_id !== "" && facebookStatus.status === "connected") {
        FB.api(VK.fb_action_instance_id, 'get', function (response) {
          if (VK.fb_action_instance_id === response.id)  {
            inviteToShareOnTwitter();
          }
        });
      }
    });
  }
}

function socialTrackingParams(facebook_action, action_id, request_id, request_to_ids) {
  var params = { petition_id: VK.petition_id, facebook_action: facebook_action };

  if (VK.signature_id !== "") { params.signature_id = VK.signature_id; }
  if (action_id !== "")       { params.action_id = action_id; }
  if (request_id !== "")      { params.request_id = request_id; }
  if (request_to_ids !== "")  { params.friend_ids = request_to_ids; }

  return params;
}

function setupSocialTrackingControllerRequest(facebook_action, action_id, request_id, request_to_ids) {
  $.ajax({
    type: 'post',
    url: VK.social_tracking_url,
    data: socialTrackingParams(facebook_action, action_id, request_id, request_to_ids)
  });
}

function setupSocialTracking() {
  try {
    if (FB && FB.Event && FB.Event.subscribe) {
      FB.Event.subscribe('edge.create', function (targetUrl) {
        _gaq.push(['_trackSocial', 'facebook', 'like', targetUrl]);
        //Google doesn't export social event data yet, so we have to track social actions as events too
        _gaq.push(['_trackEvent', 'facebook', 'like', targetUrl]);
        setupSocialTrackingControllerRequest('like');
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
            setupSocialTrackingControllerRequest('share', response.id, '', '');
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

  $('.fb_popup_btn').click(function() {
    openPopup();
    setupSocialTrackingControllerRequest('popup');
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
    setupSocialTrackingControllerRequest('wall');
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
      setupSocialTrackingControllerRequest('request', '', response.request, response.to);
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

function bindFacebookRequestAutofillFriendsButton() {
  function requestCallbackForAutofillFriendsRequest(response) {
    if(response && response.request) {
      setupSocialTrackingControllerRequest('autofill_request', '', response.request, '');
    }
    inviteToShareOnTwitter();
  }

  function sendAutofillFriendRequests() {
    FB.ui({method: 'apprequests',
      message: VK.petition_title,
      to: VK.facebook_friend_ids
    }, requestCallbackForAutofillFriendsRequest);
  }

  $('.fb_autofill_request_btn').click(sendAutofillFriendRequests);
}

function wasSigned() {
  return $("#petition_page").hasClass("was_signed");
}

function drawModalAfterSigning() {
  var modal = $("#thanksModal");
  if (screen.width > 480 && modal.length && wasSigned()) {
    modal.modal('toggle');
  }
  if ($('.fb_image_holder').length > 0) {
    modalFbImageRotator();
  }
  changeSidebar();
}

function mobileSignErrorHandling() {
  if (($('.sidebar_test').find('.help-inline').length > 0) && (screen.width < 768)) {
    $('.sidebar_test').show();
  }
}

function initMobileSign() {
  $('.mobile_signup_button').click(function() {
    $('.sidebar_test').show();
    $('body').animate({scrollTop:'40px'}, '0');
    return false;
  });
}

function initShowPetition() {
  mobileSignErrorHandling();
  initMobileSign();
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

function initModalColor() {
  if (VK.modal_coloring === 'white-box-on-blackout') {
    $('body').addClass('blackout_modal');
  }
}

function updateCounter() {
  $('.tickcounter').each(function(idx, tc) {
    var counter = parseInt(tc.innerHTML.replace(/,/g, ''), 10) + 1;
    counter = counter.toString();
    var addcomma = /(\d+)(\d{3})/;
    while (addcomma.test(counter)) {
      counter = counter.replace(addcomma, '$1' + ',' + '$2');
    }
    tc.innerHTML = counter;
  });
  setTimeout(updateCounter, 1500);
}

function initSharePetition() {
  initModalColor();
  //initTwitter();
  initFacebookApp();
  setupSocialTracking();
  setupShareFacebookButton();
  bindFacebookPopupButton();
  bindFacebookWidgetButton();
  bindFacebookRequestButton();
  bindFacebookRequestAutofillFriendsButton();
  if ($("#mobile_thanks").length > 0 && wasSigned()) {
    $('body').animate({ scrollTop: '-40px' }, '0');
  }
  if ($('.tickcounter').length > 0) { updateCounter(); }
}

function toggleUserCanSignPetition(enabledFlag) {
  var CLASSES = "btn-danger btn-primary";
  if (enabledFlag) {
    $("#sign_petition").removeAttr("disabled").addClass(CLASSES);
  } else {
    $("#sign_petition").attr("disabled", "disabled").removeClass(CLASSES);
  }
}

function clearAllSignatureErrors() {
  $(".control-group").removeClass("error").find(".alert-error").remove();
}

function updatePageToReflectUserSignature(data) {
  clearAllSignatureErrors();
  VK.signature_id = data.signature_id;
  $("#petition_page").removeClass("not_signed").addClass("was_signed");
  $("#thanks-for-signing-message.thanks_first_name").text(data.member.first_name);
  if (window.history && window.history.pushState) {
    window.history.pushState({}, "", data.url);
  }
}

function indicateUserPetitionSignedAfterAjax(data) {
  updatePageToReflectUserSignature(data);
  initSharePetition();
  drawModalAfterSigning();
}

function shareAfterUserPetitionSigned(data) {
  updatePageToReflectUserSignature(data);
  initSharePetition();
  $("#thanksModal .btn.share").click();
}

function indicateUserSignatureFailedAfterAjax(response) {
  clearAllSignatureErrors();
  var data = JSON.parse(response.responseText);
  for (var field in data) {
    var htmlField = $("[name='signature[" + field + "]']"),
        error = $("<span/>").addClass("help-inline alert alert-error").text(data[field][0]);
    htmlField.closest(".control-group").addClass("error").append(error);
  }
  toggleUserCanSignPetition(true);
}


$(document).ready(function() {
  $("#sign_petition, #sign_petition_and_share").click(function(evt) {
    var button = $(this),
        form = button.closest("form");

    evt.preventDefault();
    toggleUserCanSignPetition(false);

    $.ajax({
      type: "post",
      url: form.attr("action"),
      data: form.serialize()
    }).success(
      button.attr("id") === "sign_petition_and_share" ?
        shareAfterUserPetitionSigned : indicateUserPetitionSignedAfterAjax
    ).fail(
      indicateUserSignatureFailedAfterAjax
    );
  });
});
