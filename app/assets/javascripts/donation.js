var donation = (function() {
  function sendDonationTrackRequest() {
    var btn = $(this),
        business = btn.data("business"),
        item_name = btn.data("item-name");


    $.post(VK.donation_tracking_url, {
      petition_id: VK.petition_id,
      referral_code: VK.ref_code,
      signature_id: VK.signature_id
    }, function() {
      window.location = buildPaypalUrl();
    });
  }

  function buildPaypalUrl() {
    var params = [
      'cmd=_donations',
      'business=' + VK.contact_email,
      'item_name=' + VK.support_email.replace(/@/, "%20"),
      'item_number=' + $.cookie('member_id'),
      'lc=US',
      'no_note=1',
      'no_shipping=1',
      'currency_code=USD',
      'bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted',
      'notify_url=http%3A%2F%2F'+location.host+'%2Fpaypal'
    ].join('&');
    return VK.paypal_uri+'?'+params;
  }

  return {
    init: function() {
      $('.donate_btn').click(sendDonationTrackRequest);
    }
  };
})();
