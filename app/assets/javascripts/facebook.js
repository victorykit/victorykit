var socialTracking = (function() {
  function init() {
    if(!(FB && FB.Event && FB.Event.subscribe)) { return; }
    FB.Event.subscribe('edge.create', onEdgeCreate);
    FB.Event.subscribe('edge.remove', onEdgeRemove);
  }

  function onEdgeCreate(url) {
    url = url + '?f=' + VK.ref_code;
    _gaq.push(['_trackSocial', 'facebook', 'like', url]);
    _gaq.push(['_trackEvent', 'facebook', 'like', url]);
    trackSharing('like');
  }

  function onEdgeRemove(url) {
    _gaq.push(['_trackSocial', 'facebook', 'unlike', url]);
    _gaq.push(['_trackEvent', 'facebook', 'unlike', url]);
  }

  function trackStatus(status) {
    sendRequest({ 
      facebook_uid: FB.getUserID(), 
      facebook_action: 'status', 
      facebook_status: status 
    });
  }

  function trackSharing(action, actionId, requestId, friendIds) {
    sendRequest(createSharingData(action, actionId, requestId, friendIds));
  }

  function createSharingData(action, actionId, requestId, friendIds) {
    return { 
      petition_id: VK.petition_id, 
      facebook_action: action,
      action_id: actionId,
      request_id: requestId,
      friend_ids: friendIds,
      signature_id: VK.signature_id,
      facebook_uid: FB.getUserID()
    };
  }

  function sendRequest(data) {
    $.ajax({ type: 'post', url: VK.social_tracking_url, data: data });
  }

  return { 
    init: init, 
    trackStatus: trackStatus, 
    trackSharing: trackSharing
  };
})();

var facebook = (function() {
  var socialTracking;
  var recommendation;

  function init(st, rec) {
    socialTracking = st;
    recommendation = rec;
    initApp();
    setupShare();
    setupPopup();
    setupDialog();
    setupRequest();
    setupRecommendation();
  }

  function initApp() {
     FB.init({
      appId: $('meta[property="fb:app_id"]').attr('content'),
      status: true, // check login status
      cookie: true, // enable cookies to allow the server to access the session
      xfbml: true,  // parse XFBML
      frictionless: true // for facebook request dialog
    });
    socialTracking.init();
    if (FB.getLoginStatus) { FB.getLoginStatus(trackFacebookStatus); }
  }

  function trackFacebookStatus(facebookStatus) {
    VK.facebook_login_status = facebookStatus.status;
    socialTracking.trackStatus(facebookStatus.status);
  }

  function sendAction() {
    function loginCallback(res) {
      if(!res.authResponse) {
        $('.fb_share_message').hide();
        return;
      }
      var petition = $('meta[property="og:url"]').attr('content');
      FB.api('/me/victorykit:sign', 'post', { petition: petition }, apiCallback);
    }

    function apiCallback(res) {
      (!res || res.error) ?
      $('.fb_share_message').text('Please try again.') :
      socialTracking.trackSharing('share', response.id, '', '');
    }

    FB.login(loginCallback, { scope: 'publish_actions' });
  }

  function setupShare() {
    $('.fb_share.btn').click(function() {
      $('.fb_share_message').text("Connecting to Facebook...").show();
      sendAction();
    });
  }

  function setupPopup() {
    $('.fb_popup_btn').click(function() {
      openPopup();
      socialTracking.trackSharing('popup');
      closeThanksModal();
    });

    function openPopup() {
      var sharer = 'https://www.facebook.com/sharer/sharer.php?u=';
      var domain = location.href.replace(/\?.*/,"");
      var referralCode = (VK.ref_code === '' ? $.cookie('ref_code') : VK.ref_code);
      var url = sharer + encodeURIComponent(domain + '?share_ref=' + referralCode);
      window.open(url , 'sharer', 'width=626,height=436');
    }
  }

  function setupDialog() {
    $('.fb_dialog_btn').click(function() {
      openDialog();
      socialTracking.trackSharing('dialog');
      closeThanksModal();
    });

    function openDialog() {
      var domain = location.href.replace(/\?.*/,"");
      var referralCode = (VK.ref_code === '' ? $.cookie('ref_code') : VK.ref_code);
      var link = [domain, '?fd=', referralCode].join('');
      var dialog = "https://www.facebook.com/dialog/feed?" +
        "app_id=" + getProperty('fb:app_id') + "&" +
        "link=" + encodeURIComponent(link) + "&" +
        "picture=" + getProperty('og:image') + "&" +
        "name=" + getProperty('og:title') + "&" +
        "description=" + getProperty('og:description') + "&" +
        "redirect_uri=http://" + location.host + "/close.html&" +
        "display=popup";
      window.open(dialog , 'dialog', 'width=626,height=436');
    }

    function getProperty(name) {
      return encodeURIComponent($('meta[property="' + name + '"]').attr('content'));
    }
  }

  function setupRequest() {
    $('.fb_request_btn').click(function() {
      FB.ui({ method: 'apprequests', message: VK.petition_title }, function(res) {
        if(res && res.request) {
          socialTracking.trackSharing('request', '', res.request, res.to);
        }
      });
      closeThanksModal();
    });
  }

  function setupRecommendation() {
    recommendation.init(socialTracking); 
  }
 
  return { init: init };
})();

