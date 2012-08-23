class BuildChecker

  def initialize rof, chat
    @rails_on_fire = rof
    @chat = chat
  end
  def run
    @rails_on_fire.log_in

    previous_build_state = {}

    while true
      current_build_state = @rails_on_fire.current_build
      previous_build_state = check_build(previous_build_state, current_build_state)
      sleep 60
    end
  end

  def check_build(previous_build = {}, current_build = {})
    if(current_build[:status] == 'error' && previous_build[:status] == 'success')
      message = "#{current_build[:builder]} broke the build"
      @chat.say message
    end
    if(current_build[:status] == 'success' && previous_build[:status] == 'error')
      @chat.say "#{current_build[:builder]} has fixed the build"
    end
    current_build
  end
end

