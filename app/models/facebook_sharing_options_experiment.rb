class FacebookSharingOptionsExperiment < TimeBandedExperiment
  include Whiplash

  def initialize session, request
    super('facebook sharing options', [Time.parse("2012-Nov-01 14:00 -0400")])

    @options = ['facebook_popup', 'facebook_request', 'facebook_recommendation', 'facebook_dialog']
    @session = session
    @request = request
  end

  def session
    @session
  end

  def request
    @request
  end

  alias super_spin! spin!

  def spin! member, browser
    return 'facebook_popup' if browser.ie7?

    sharing_option = super_spin! name_as_of(Time.now), :referred_member, @options
    spin_request_subexperiment sharing_option, member
  end

  def win! reference, ref_time
    reference = win_request_pick_vs_autofill reference
    win_on_option! name_as_of(ref_time), reference
  end

  private

  def spin_request_subexperiment sharing_option, member
    request_default = "facebook_request"
    return sharing_option unless sharing_option == request_default
    return request_default unless member.present?
    fb_friend = FacebookFriend.find_by_member_id(member.id)
    fb_friend.present? ?
      (super_spin! 'facebook request pick vs autofill', :referred_member, [request_default, 'facebook_autofill_request']) :
      request_default
  end

  def win_request_pick_vs_autofill reference
    if(reference == 'facebook_request' || reference == 'facebook_autofill_request')
      win_on_option! 'facebook request pick vs autofill', reference
      reference = 'facebook_request'
    end
    reference
  end

end