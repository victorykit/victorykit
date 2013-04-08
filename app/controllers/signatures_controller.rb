class SignaturesController < ApplicationController

  before_filter :require_admin, only: [:index]

  def index
    respond_to do |format|
      format.csv {
        self.response.headers["Content-Type"] = 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; signatures-#{params[:petition_id]}.csv"
        self.response.headers['Last-Modified'] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |y|
          i = 0
          Signature.where(petition_id: params[:petition_id]).find_each do |signature|
            y << signature.csv_header.to_csv if i == 0
            y << signature.csv_values.to_csv
            i += 1
            GC.start if i%500==0
          end
        end
      }
    end
  end

  def create
    petition = Petition.find(params[:petition_id])

    # trailing periods cause SES to reject emails
    params[:signature][:email] = params[:signature][:email].chomp(".") if params[:signature] and params[:signature][:email]

    signature = Signature.new(params[:signature])
    signature.ip_address = connecting_ip
    signature.user_agent = browser.user_agent
    signature.browser_name = browser.id.to_s
    email = signature.email
    member = Member.find(:first, conditions: ["lower(email)=?", email.try(:downcase)])
    signature.member = (member || Member.new).tap do |m|
      m.first_name = signature.first_name
      m.last_name = signature.last_name
      m.email = email unless m.email
    end
    signature.created_member = signature.member.new_record?
    signature.member.save
    signature.http_referer = retrieve_http_referer
    ref_code = Referral.where(code: params[:signer_ref_code]).first || Referral.new(code: params[:signer_ref_code])
    if signature.valid?
      begin
        petition.signatures.push signature
        petition.save!
        signature.track_referrals(params)
        signature.save!
        ref_code.member_id = signature.member.id
        ref_code.petition_id = petition.id
        ref_code.save!

        begin
          Resque.enqueue(SignedPetitionEmailJob, signature.id)
        rescue => ex
          notify_airbrake(ex)
          Rails.logger.error "Error queueing email on Resque: #{ex} #{ex.backtrace.join}"
          Notifications.signed_petition Signature.find(signature.id)
        end

        nps_win signature
        win! :signature
        cookies[:member_id] = { :value => signature.member.to_hash, :expires => 100.years.from_now }
        cookies[:ref_code] = { :value => ref_code.code, :expires => 100.years.from_now }

        flash[:signature_id] = signature.id
      rescue => ex
        notify_airbrake(ex)
        Rails.logger.error "Error saving signature: #{ex} #{ex.backtrace.join}"
        flash.notice = ex.message
      end
    end

    respond_to do |format|
      format.json { 
        if signature.valid?
          render json: { signature_id: signature.id, url: petition_url(petition, l: ref_code.code), share_url: petition_url(petition, ls: ref_code.code), member: signature.member.attributes.slice(:first_name, :last_name, :email) }
        else
          render json: signature.errors, status: 400
        end
      }
      format.html { 
        flash[:invalid_signature] = signature unless signature.valid?
        redirect_to petition_url(petition, l: signature.valid? ? ref_code.code : nil)
      }
    end
  end

  private
  
  def nps_win signature
    $statsd.increment "signatures_from_emails.count" if signature.reference_type == "email"

    return unless signature.created_member
    win_on_option!('email_scheduler_nps', signature.petition.id.to_s)
  
    if FacebookSharingOptionsExperiment.applicable_to? signature
      FacebookSharingOptionsExperiment.new(self).win! signature
    end
  end
end
