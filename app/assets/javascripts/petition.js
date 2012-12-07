function trackDonationClick(){
  $.post(VK.donation_tracking_url, {
    petition_id: VK.petition_id, 
    referral_code: VK.ref_code,
    signature_id: VK.signature_id
  });
}

function setupDonation() {
  var params = [
    'cmd=_donations',
    'business=info@demandprogress.org',
    'lc=US',
    'item_name=Support%20Watchdog.net',
    'item_number='+$.cookie('member_id'),
    'no_note=1',
    'no_shipping=1',
    'currency_code=USD',
    'bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted',
    'notify_url=http%3A%2F%2F'+location.host+'%2Fpaypal'
  ].join('&');
  var url = VK.paypal_uri+'?'+params;
  $('.donate_btn').attr('href', url).click(trackDonationClick);
}

function closeThanksModal(toggleAfterShareModal) {
  $("#thanksModal").modal('hide');
  if (toggleAfterShareModal === undefined) { $('#thanksAfterSharingModal').modal('toggle'); }
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

function wasSigned() {
  return $("#petition_page").hasClass("was_signed");
}

function drawModalAfterSigning() {
  var modal = $("#thanksModal");
  if (screen.width > 480 && modal.length && wasSigned()) {
    modal.modal('toggle');
  }

  function fb_flip() {
    $('.share_button').toggleClass("hide");
    $('.share_link').toggleClass("hide");
  }

  if ($(".share_button").length > 0) {
    if (VK.facebook_login_status == 'unknown') { fb_flip(); }
    $('.fb_toggle').click(fb_flip);
    if (!/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) ) {
      $('.share_url').click( function() {
        $(this).select();
      });
    }
  }
}

function mobileSignErrorHandling() {
  if (($('.sidebar').find('.help-inline').length > 0) && (screen.width < 768)) {
    $('.sidebar').show();
  }
}

function initMobileSign() {
  $('.mobile_signup_button').click(function() {
    $('.sidebar').show();
    $('.progress_box').hide();
    $('body').animate({scrollTop:'40px'}, '0');
    return false;
  });
}

function initShowPetition() {
  mobileSignErrorHandling();
  initMobileSign();
  preventWhitespaceOn('#signature_email');
  socialTracking.init();

  $('form').on("submit", function (event) {
    if (!VK.signing_from_email) {
      var emailSuggestor = new EmailSuggestions();
      emailSuggestor.init();
      emailSuggestor.mailCheckSuggestions(event);
    }
    return event.go;
  });
  if ($(".focused").length > 0 && !wasSigned()) {
    $('body').animate({ scrollTop: '-30px' }, '0');
    $('.petition_view_toggle').click( function() {
      $(this).hide();
      $('.petition_body').show();
    });
  }
  if ($(".privacypolicy .centered").length > 0) {
    $('.toggle_tooltip').hover( function() {
      $('.privacy_tooltip').toggle();
    });
  }
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
  facebook.init(socialTracking, recommendation);
  if($("#mobile_thanks").length > 0 && wasSigned()) {
    $('body').animate({ scrollTop: '-40px' }, '0');
  }
  if($('.tickcounter').length > 0) {
    updateCounter(); 
  }
  setupDonation();
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
  if(VK) { VK.signature_id = data.signature_id; }
  else { VK = { signature_id: data.signature_id }; }
  $(".share_url").attr("value", data.share_url);
  $("#petition_page").removeClass("not_signed").addClass("was_signed");
  $("#thanks-for-signing-message.thanks_first_name").text(data.member.first_name);
  if (window.history && window.history.pushState) {
    window.history.pushState({}, "", data.url);
  }
}

function indicateUserPetitionSignedAfterAjax(data) {
  $('.progress_box').hide();
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
