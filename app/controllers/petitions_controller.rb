require 'sent_email_hasher'
require 'member_hasher'

class PetitionsController < ApplicationController
  before_filter :require_login, except: [:show]
  before_filter :track_visit, only: :show
  before_filter :require_admin, only: :index

  def index
    @petitions = Petition.order 'created_at DESC'
  end

  def show
    @petition = Petition.find(params[:id])
    @sigcount = @petition.signatures.count

    @referring_url = request.original_url

    @current_member_hash = cookies[:member_id]
    @referring_member_hash = params[:r] || params[:t] || params[:f] || params[:share_ref]

    @email_hash = params[:n]
    @forwarded_notification_hash = params[:r]
    @shared_link_hash = params[:l]

    @twitter_hash = params[:t]
    @fb_like_hash = params[:f]
    @fb_share_link_ref = params[:share_ref]
    @fb_action_id = params[:fb_action_ids]
    @existing_fb_action_instance_id = Share.where(member_id: get_member_id, petition_id: params[:id]).first.try(:action_id)

    signature_id = get_signature_id @petition
    @was_signed = signature_id.present?
    @tweetable_url = "http://#{request.host}#{request.fullpath}?t=#{cookies[:member_id]}"
    unless @signature = flash[:invalid_signature]
      @just_signed = flash[:signature_id].present?
      @signature = Signature.new
      prepopulate_signature
      @signature.id = signature_id
    end
  end

  def new
    @petition = Petition.new
    @form_view = choose_form_based_on_browser
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
      log_empty_links
      experiment_seeding_signature
      redirect_to @petition, notice: 'Petition was successfully created.'
    else
      refresh "new"
    end
  end

  def update
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
    if @petition.update_attributes(params[:petition], as: role)
      log_empty_links

      redirect_to @petition, notice: 'Petition was successfully updated.'
    else
      refresh "edit"
    end
  end

  def send_email_preview
    @petition = params[:id].present? ? Petition.find(params[:id]) : Petition.new
    @petition.assign_attributes(params[:petition], as: role)
    current_member = Member.find_by_email current_user.email
    ScheduledEmail.send_preview @petition, current_member
    respond_to do |format|
      format.json  { render :json => ['success'].to_json }
    end
  end

  private

  def get_member_id
    MemberHasher.validate(cookies[:member_id])
  end

  def refresh action
    flash[:error] = @petition.errors.full_messages.to_sentence if @petition.errors.any?
    @form_view = choose_form_based_on_browser
    render action: action
  end

  def log_empty_links
    #this is an attempt to detect petitions created with empty links (no 'href' attribute) with the wysihtml5 editor
    #remove when we've found the issue!
    begin
      doc = Nokogiri::HTML(@petition.description)
      if doc.xpath("//a[not(@href)]").any?
        flash[:error] = "This petition contains an empty link - please check and correct if necessary"

        Rails.logger.error "Petition #{@petition.id} contains an empty link"
        Rails.logger.info @petition.description
      end
    rescue => ex
      Rails.logger.warn "Failed to parse petition #{@petition.id}'s description (#{ex})"
    end
  end

  def get_signature_id petition
    if member_id = get_member_id
      Signature.where(:petition_id => petition.id, :member_id => member_id).last.try(:id)
    else
      nil
    end
  end

  def choose_form_based_on_browser
    if browser.ie? and !(browser.user_agent =~ /chromeframe/)
      'ie_form'
    else
      'form'
    end
  end

  def prepopulate_signature
    begin
      if email_id = SentEmailHasher.validate(@email_hash) then sent_email = SentEmail.find_by_id(email_id) end
      if !populate_member_from_cookies && sent_email && sent_email.signature_id.nil?
        @signature.name =  sent_email.member.name
        @signature.email = sent_email.member.email
        @signing_from_email = true
      end
    rescue => er
      Rails.logger.error "Error while prepopulating member info: #{er} #{er.backtrace.join}"
    end
  end

  def populate_member_from_cookies
    if member_id = get_member_id
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
      rescue => ex
        flash.notice = ex.message
      end
    end
  end

end
