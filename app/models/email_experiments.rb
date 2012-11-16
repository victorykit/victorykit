class EmailExperiments
  include PersistedExperiments

  def initialize(email)
    @email = email
  end

  def subject
    default = @email.petition.title
    test_name = "petition #{@email.petition.id} #{PetitionTitle::TitleType::EMAIL} title"
    spin!(test_name, :signature, title_options.map{|opt| opt.title}, default)
  end

  def image_url
    spin!("petition #{@email.petition.id} image", :signature, image_url_options.map{|opt| opt.url})
  end

  def demand_progress_introduction_location
    default_intro_location = "top"
    hide_demand_progress_intro? ? default_intro_location : (spin! "demand progress introduction location", :signature, intro_location_options)
  end
  
  def ask_to_sign_text
    spin! "ask to sign text", :signature, ask_to_sign_text_options
  end

  def font_size_of_petition_link
    spin! "font size of sign-this-petition link", :signature, font_size_options
  end

  def button_color_for_petition_link
    spin! "button color for sign-this-petition link", :signature, button_color_options
  end

  def button_color_for_share_petition_link
    spin! "button color for share-this-petition link", :signature, share_button_color_options
  end

  def show_button_instead_of_link
    spin! "show button instead of link", :signature
  end

  def show_facebook_share_button
    spin! "show facebook share button", :signature
  end

  def show_ps_with_plain_text
    (spin! "show ps with plain text", :signature, display_options) == "show" || false
  end

  def show_less_prominent_unsubscribe_link
    spin! "show less prominent unsubscribe link", :unsubscribe
  end

  def petition_short_summary
    short_summaries = @email.petition.petition_summaries.map(&:short_summary)
    spin! "petition #{@email.petition.id} email short summary", :signature, short_summaries if short_summaries.any?
  end

  def hide_demand_progress_intro?
    previously_signed = Signature.where("member_id = ?", @email.member_id).present?
    previously_opened_or_clicked_email = SentEmail.where("member_id = ? AND (opened_at IS NOT ? OR clicked_at IS NOT ?)", @email.member_id, nil, nil).present?
    previously_signed || previously_opened_or_clicked_email
  end

  private

  def title_options
    PetitionTitle.find_all_by_petition_id_and_title_type(@email.petition.id, PetitionTitle::TitleType::EMAIL)
  end

  def image_url_options
    @email.petition.petition_images
  end

  def intro_location_options
    ["top", "bottom"]
  end

  def display_options
    ["show", "hide"]
  end

  def ask_to_sign_text_options
    ["Click here to sign -- it just takes a second.", "Sign this petition now.",
      "SIGN THIS PETITION", "Please, click here to sign now!"]
  end

  def font_size_options
    ["100%", "125%", "150%", "200%"]
  end

  def button_color_options
    ["#990000", "#308014"]
  end

  def share_button_color_options
    ["#999999"]
  end

  # persisted experiments templates

  def current_trials(goal)
    EmailExperiment.find_all_by_sent_email_id_and_goal(@email.id, goal)
  end

  def current_trial(goal, test_name)
    EmailExperiment.find_by_sent_email_id_and_goal_and_key(@email.id, goal, test_name)
  end

  def create_trial(goal, test_name, choice)
    EmailExperiment.new(sent_email_id: @email.id, goal: goal, key: test_name, choice: choice)
  end

  def trial_session
    {:session_id => @email.id.to_s}
  end

end
