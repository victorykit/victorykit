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
    @fb_dialog_request = params[:d]
    @existing_fb_action_instance_id = Share.where(member_id: member_from_cookies.try(:id), petition_id: params[:id]).first.try(:action_id)

    @member = member_from_cookies || member_from_email
    @was_signed = member_from_cookies.present? && member_from_cookies.signed?(@petition)

    @signature = flash[:invalid_signature] || @petition.signatures.build
    @signature.prepopulate(@member) if @member.present? && !@member.signed?(@petition)

    # TODO Remove this - this is not the right way to propagate member information to the SocialTracking controller.
    @signature.id = Signature.where(member_id: @member.try(:id), petition_id: @petition.id).first.try(:id)
    
    @just_signed = flash[:signature_id].present?
    @signing_from_email = sent_email.present? && !@was_signed

    @tweetable_url = "http://#{request.host}#{request.fullpath}?t=#{cookies[:member_id]}"
  end

  def new
    @petition = Petition.new
  end

  def edit
    @petition = Petition.find(params[:id])
    return render_403 unless @petition.has_edit_permissions(current_user)
  end

  def create
    @petition = Petition.new(params[:petition], as: role)
    @petition.owner = current_user
    @petition.ip_address = connecting_ip

    if @petition.save
      log_empty_links
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
    current_member = Member.find_or_initialize_by_email(email: current_user.email, name: "Admin User")
    ScheduledEmail.send_preview @petition, current_member
    respond_to do |format|
      format.json  { render :json => ['success'].to_json }
    end
  end

  private

  def refresh action
    flash[:error] = @petition.errors.full_messages.to_sentence if @petition.errors.any?
    render action: action
  end

  def log_empty_links
    #this is an attempt to detect petitions created with empty links (no 'href' attribute) with the wysihtml5 editor
    #remove when we've found the issue!
    doc = Nokogiri::HTML(@petition.description)
    if doc.xpath("//a[not(@href)]").any?
      flash[:error] = "This petition contains an empty link - please check and correct if necessary"

      Rails.logger.error "Petition #{@petition.id} contains an empty link"
      Rails.logger.info @petition.description
    end
  rescue => ex
    Rails.logger.warn "Failed to parse petition #{@petition.id}'s description (#{ex})"
  end

  def sent_email
    SentEmail.find_by_hash(params[:n])
  end
  memoize :sent_email

  def member_from_cookies
    Member.find_by_hash(cookies[:member_id])
  end
  memoize :member_from_cookies

  def member_from_email
    sent_email.try(:member)
  end
  memoize :member_from_email

  def track_visit
    sent_email.track_visit! if sent_email.present?
  end
end
