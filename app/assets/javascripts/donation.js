var donation = (function() {
  function sendDonationTrackRequest(){
    $.post(VK.donation_tracking_url, {
      petition_id: VK.petition_id, 
      referral_code: VK.ref_code,
      signature_id: VK.signature_id
    });
  }

  return {
    init: function() {
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
      $('.donate_btn').attr('href', url).click(sendDonationTrackRequest);
    }
  };
})();
