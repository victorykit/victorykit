require 'sent_email_hasher'
require 'member_hasher'

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
    @fb_hash = params[:fb_ref]
    @fb_tracking_hash = cookies[:member_id]
    @was_signed = was_petition_signed @petition

    unless @signature = flash[:invalid_signature]
	    @signature_id = flash[:signature_id]
	    @just_signed = !@signature_id.nil?
      @signature = Signature.new
      prepopulate_signature
    end
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
    @form_view = choose_form_based_on_browser
    return render_403 unless @petition.has_edit_permissions(current_user)
  end

  def create
    @petition = Petition.new(params[:petition], as: role)
    @petition.owner = current_user
    @petition.ip_address = connecting_ip

    if @petition.save
      experiment_seeding_signature
      redirect_to @petition, notice: 'Petition was successfully created.'
    else
      @form_view = choose_form_based_on_browser
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

  def was_petition_signed petition
    if member_id = MemberHasher.validate(cookies[:member_id])
      Signature.where(:petition_id => petition.id, :member_id => member_id).any?
    else
      false
    end
  end


  def prepopulate_signature
    begin
      if email_id = SentEmailHasher.validate(@email_hash) then sent_email = SentEmail.find_by_id(email_id) end
      if sent_email && sent_email.signature_id.nil?
        @signature.name =  sent_email.member.name
        @signature.email = sent_email.member.email
        @signing_from_email = true
      else
        populate_member_from_cookies
      end
    rescue => er
      Rails.logger.error "Error while prepopulating member info: #{er} #{er.backtrace.join}"
    end
  end

  def populate_member_from_cookies
    if member_id = MemberHasher.validate(cookies[:member_id])
      member = Member.find member_id
      @signature.name = member.name
      @signature.email = member.email
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

  #todo: This is largely copied from SignaturesController.create - refactor commonality if experiment wins
  def experiment_seeding_signature
    return if not spin! "seed signatures with petition creator", :signature

    email = current_user.email
    member = Member.find_by_email(email)
    name = member.name unless not member
    name = name.nil? ? email[/^[^@]+/] : name

    signature = Signature.new(:name => name, :email => email)
    signature.ip_address = request.remote_ip
    signature.user_agent = request.env["HTTP_USER_AGENT"]
    signature.member = Member.find_or_initialize_by_email(email: email, name: name)
    signature.created_member = signature.member.new_record?

    if signature.valid?
      begin
        @petition.signatures.push signature
        petition.save!
      rescue => ex
        flash.notice = ex.message
      end
    end
  end

end
