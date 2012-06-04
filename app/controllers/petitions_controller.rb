require 'sent_email_hasher'
require 'signature_hasher'

class PetitionsController < ApplicationController
  before_filter :require_login, except: [:show]
  before_filter :track_visit, only: :show
  before_filter :require_admin, only: :index

  def index
    @petitions = Petition.all
  end

  def show
    @petition = Petition.find(params[:id])
    @sigcount = @petition.signatures.count
    @email_hash = params[:n]
    @fb_tracking_hash = @email_hash || SignatureHasher.generate(session[:last_signature_id])
    @signature = Signature.new
    prepopulate_signature
  end

  def new
    @petition = Petition.new
	  @form_view = choose_form_based_on_browser
  end

  def choose_form_based_on_browser
 		if browser.ie? and !(browser.user_agent =~ /chromeframe/)
       'ie_form'
     else
       'form'
 		end
 	end

  def edit
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
  end

  def create
    @petition = Petition.new(params[:petition], as: role)
    @petition.owner = current_user
    @petition.ip_address = request.remote_ip

    if @petition.save
      redirect_to @petition, notice: 'Petition was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
    if @petition.update_attributes(params[:petition], as: role)
      redirect_to @petition, notice: 'Petition was successfully updated.'
    else
      render action: "edit"
    end
  end

  private

  def prepopulate_signature
    if email_id = SentEmailHasher.validate(@email_hash) then sent_email = SentEmail.find_by_id(email_id) end
    if sent_email
      @signature.name =  sent_email.member.name
      @signature.email = sent_email.member.email
    else
      @signature.name =  session[:signature_name]
      @signature.email = session[:signature_email]
    end
  end

  def track_visit
    if sent_email_id = SentEmailHasher.validate(params[:n])
      begin
        sent_email = SentEmail.find(sent_email_id)
        sent_email.update_attributes(clicked_at: Time.now) unless sent_email.clicked_at
      rescue => error
        Rails.logger.error "Error while trying to record clicked_at time for petition: #{error}"
      end
    end
  end
end
