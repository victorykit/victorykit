class EmailExperiments
  include PersistedExperiments

  def initialize(email)
    @email = email
  end

  def subject
    default = @email.petition.title
    test_name = "petition #{@email.petition.id} #{PetitionTitle::TitleType::EMAIL} title"
    spin!(test_name, :signature, title_options, default)
  end

  def image_url
    url = spin!(image_experiment_key, :signature, image_url_options)
    url ? PetitionImage.find_by_url(url).public_url : url
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
    spin!("show facebook share button", :signature, display_options) == "show"
  end

  def show_ps_with_plain_text
    spin!("show ps with plain text", :signature, display_options) == "show"
  end

  def show_less_prominent_unsubscribe_link
    spin! "show less prominent unsubscribe link", :unsubscribe
  end

  def from_address
    spin! "from address", :signature, from_address_options
  end

  def petition_short_summary
    short_summaries = short_summary_options
    spin!(summary_experiment_key, :signature, short_summaries) if short_summaries.any?
  end

  def best_image petition
    options = image_url_options
    unless options.empty?
      url = winning_option(image_experiment_key, options)
      url ? PetitionImage.find_by_url(url).public_url : url
    end
  end

  def best_summary petition
    options = short_summary_options
    winning_option(summary_experiment_key, options) unless options.empty? 
  end

  private

  def title_options
    PetitionTitle.find_all_by_petition_id_and_title_type(@email.petition.id, PetitionTitle::TitleType::EMAIL).map(& :title)
  end

  def image_url_options
    @email.petition.petition_images.map(& :url)
  end

  def short_summary_options
    @email.petition.petition_summaries.map(&:short_summary)
  end

  def image_experiment_key
    "petition #{@email.petition.id} image"
  end

  def summary_experiment_key
    "petition #{@email.petition.id} email short summary"
  end
  
  def display_options
    ["show", "hide"]
  end

  def button_color_options
    ["#990000", "#308014"]
  end

  def share_button_color_options
    ["#999999"]
  end

  def from_address_options
    [Settings.email.from_address, Settings.email.from_address2]
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
