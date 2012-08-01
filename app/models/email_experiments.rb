class EmailExperiments
  include PersistedExperiments

  def initialize(email)
    @email = email
  end

  def subject
    default = @email.petition.title
    test_name = "petition #{@email.petition.id} #{PetitionTitle::TitleType::EMAIL} title"
    spin_or_default!(test_name, :signature, title_options.map{|opt| opt.title}, default)
  end

  def summary_box
     spin_or_retrieve_choice "insert summary box to emails", :signature, [true, false]
  end

  def sender
    spin_or_retrieve_choice "different from lines for scheduled emails", :signature, sender_options
  end

  def image_url
    spin_or_default!("petition #{@email.petition.id} image", :signature, image_url_options.map{|opt| opt.url}, nil)
  end

  def demand_progress_introduction
    previously_signed = Signature.where("email = ?", @email.email).present?
    previously_opened_or_clicked_email = SentEmail.where("email = ? AND opened_at IS NOT ? OR clicked_at IS NOT ?", @email.email, nil, nil).present?
    if previously_signed || previously_opened_or_clicked_email
      display_introduction_experiment = spin_or_retrieve_choice "hide demand progress introduction in email", :signature, display_options
    end
    display_introduction_experiment.present? ? display_introduction_experiment == "hide" : false
  end

  private

  def title_options
    PetitionTitle.find_all_by_petition_id_and_title_type(@email.petition.id, PetitionTitle::TitleType::EMAIL)
  end

  def sender_options
    [Settings.email.from_address, Settings.email.from_address2, Settings.email.from_address3,
      Settings.email.from_address4, Settings.email.from_address5, Settings.email.from_address6]
  end

  def image_url_options
    @email.petition.petition_images
  end

  def display_options
    ["show", "hide"]
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
