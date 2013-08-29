def signin email, pass
  visit '/'
  click_link 'Sign Up or Log In'
  within '#new_user' do
    fill_in 'Email', with: email
    fill_in 'user_password', with: pass
    fill_in 'user_password_confirmation', with: pass
    click_button 'Sign Up'
  end
  yield
  find('a.logged-in-menu').click
  click_link 'Log Out'
end

def login email, pass
  visit '/login'
  within 'form[action="/users/sign_in"]' do
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    click_button 'Log in'
  end
  val = yield
  find('a.logged-in-menu').click
  click_link 'Log Out'
  val
end

def sign petition, params=nil
  path = params ?
    petition_path(petition, params) :
    petition_path(petition)
  visit path
  sign_at_petition
end

def sign_at_petition(first_name = 'Peter', last_name = 'Griffin', email = 'peter@example.com')
  fill_in 'First name', with: first_name
  fill_in 'Last name', with: last_name
  fill_in 'Email', with: email
  click_button 'sign_petition'
end

def create_petition params={}
  params = petition_defaults.merge params
  visit new_petition_path
  #page.driver.resize_window(1680, 1050)
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

def experiment_results_for test_name, filter=nil
  url = "/admin/experiments"
  url << "?f=#{filter}" if filter
  visit url

  selector = "table[data-title='#{test_name}']"

  all("#{selector} tbody tr").inject({}) do |out, e|
    out.merge e.find("td.name").text => {
      spins: e.find("td.spins").text.to_i,
      wins:  e.find("td.wins").text.to_i
    }
  end
end

def email_experiment_results_for petition
  experiment_results_for "petition #{petition.id} email title", "petitions"
end

def opengraph_image
  find('meta[property="og:image"]')[:content]
end
