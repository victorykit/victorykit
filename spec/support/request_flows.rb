def signin email, pass
  visit '/'
  click_link 'Sign Up or Log In'
  within '#new_user' do
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    fill_in 'Password confirmation', with: pass
    click_button 'Sign Up'
  end
  yield
  click_link 'Log Out'
end

def login email, pass
  visit '/'
  click_link 'Sign Up or Log In'
  within 'form[action="/sessions"]' do
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    click_button 'Log in'
  end
  yield
  click_link 'Log Out'
end

def sign petition, params=nil
  path = params ? 
  petition_path(petition, params) : 
  petition_path(petition)

  visit path
  fill_in 'First name', with: 'Peter'
  fill_in 'Last name', with: 'Griffin'
  fill_in 'Email', with: 'peter@gmail.com'
  click_button 'Sign!'
end

def create_petition params={}
  params = petition_defaults.merge params
  visit new_petition_path
  fill_in 'Title', with: params[:title]
  fill_in_description_with params[:description]
  fill_in_subjects params[:subjects]
  fill_in_fb_titles params[:fb_titles]
  fill_in_images params[:images]
  click_button 'Create Petition'
  wait_until do
    page.has_content? 'Petition was successfully created'
  end
  Petition.last
end

def petition_defaults
  { title: 'I like Turtles',
    description: 'Turtles are awesome!' }
end

def fill_in_subjects subjects
  return unless subjects
  click_link 'Customize Email Subject'
  subjects[1..-1].each{ click_link 'Add Email Subject' }

  within '#email_subjects' do
    all('input[type="text"]').each_with_index do |e, i|
      e.set subjects[i]
    end   
  end
end

def fill_in_fb_titles titles
  return unless titles
  click_link 'Customize Facebook Title'
  titles[1..-1].each{ click_link 'Add Facebook Title' }

  within '#facebook_titles' do
    all('input[type="text"]').each_with_index do |e, i|
      e.set titles[i]
    end
  end
end

def fill_in_images images
  return unless images
  click_link 'Customize Image'
  images[1..-1].each{ click_link 'Add Image' }

  within '#sharing_images' do
    all('input[type="text"]').each_with_index do |e, i|
      e.set images[i]
    end
  end
end

def force_result params
  visit '/whiplash_sessions'
  params.each do |field, value|
    fill_in field, with: value
  end
  click_button 'Update'
end

# for petition/new only with js on
def fill_in_description_with text
  page.execute_script(
    "$('#petition_description').data('wysihtml5')\
      .editor.composer.setValue('#{text}');")
end

def on_demand_email_path petition, member
  "/admin/on_demand_email/new?petition_id=#{petition.id}&member_id=#{member.id}"
end

def email_experiment_results_for petition
  visit '/admin/experiments?f=petitions'
  selector = "table[id='petition #{petition.id} email title']"
  { spins: find("#{selector} td.spins").text.to_i, 
    wins:  find("#{selector} td.wins").text.to_i }
end

def opengraph_image
  find('meta[property="og:image"]')[:content]
end