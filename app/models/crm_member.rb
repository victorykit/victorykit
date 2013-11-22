class CrmMember
  include ActiveAttr::Model

  attribute :id
  attribute :email
  attribute :prefix
  attribute :first_name
  attribute :middle_name
  attribute :last_name
  attribute :suffix
  attribute :address1
  attribute :address2
  attribute :city
  attribute :state
  attribute :state_code
  attribute :country
  attribute :country_code
  attribute :postal_code
  attribute :region
  attribute :created_at

  def address
    self.address1
  end

  def address=(a)
    self.address1 = a
  end

  def zip_code
    self.postal_code
  end

  def zip_code=(zip)
    self.postal_code = zip
  end

end