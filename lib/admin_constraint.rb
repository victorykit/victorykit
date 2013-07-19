class AdminConstraint
  def matches?(request)
    return false if request.session[:user_id].blank?
    u = User.where(id: request.session[:user_id]).first
    u.present? && ( u.is_super_user || u.is_admin )
  end
end