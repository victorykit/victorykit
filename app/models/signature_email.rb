class SignatureEmail < SentEmail
  attr_accessible :signature
  # CONFUSION ALERT!
  # These emails are triggered by a user signing a petition, but the signature
  # attribute is not that signature. It is the signature that may arise from a
  # referral initiated from the sent email.
  belongs_to :signature
end
