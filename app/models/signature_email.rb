class SignatureEmail < SentEmail
  attr_accessible :signature
  #CONFUSION ALERT! This is not the signature that triggered the sending of this email. It is the signature that
  #(may) arise from a referral off this email.
  belongs_to :signature
end
