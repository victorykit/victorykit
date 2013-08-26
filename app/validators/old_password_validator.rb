class OldPasswordValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    old_user = User.find(object.id)
#    unless old_user.authenticate value
    unless sign_in old_user, attribute => value
      object.errors[attribute] << (options[:message] || " is not your previous password")
    end
  end
end
