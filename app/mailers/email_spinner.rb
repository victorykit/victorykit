#can't see any way to test ActionMailer instance methods, so this gets pulled into a class
class EmailSpinner
  include Bandit
  def do_spin!(email, test_name, goal, options)
    session = {:session_id => email.id.to_s}
    choice = spin!(test_name, goal, options, session)
    add_spin_data email, goal, test_name, choice
    return choice
  end

  private 

  def add_spin_data email, goal, test_name, choice
    experiment = EmailExperiment.new
    experiment.sent_email_id = email.id
    experiment.goal = goal
    experiment.key = test_name
    experiment.choice = choice
    experiment.save!
  end
end
