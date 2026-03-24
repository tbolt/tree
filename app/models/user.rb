class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = "no-reply@tree.fly.dev"
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes
  
  attr_accessor :current_password
  
  has_secure_password
  
  has_many :active_sessions, dependent: :destroy
  has_many :sent_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :received_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :sent_follows, source: :followed
  has_many :followers, through: :received_follows, source: :follower
  has_many :posts, dependent: :destroy
  
  before_save :downcase_email
  before_save :downcase_unconfirmed_email
  
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}
  validates :display_name, length: {maximum: 50}
  validates :bio, length: {maximum: 160}
  
  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)
  
    raise ArgumentError, "One or more password arguments are required" if passwords.empty?
    raise ArgumentError, "One or more finder arguments are required" if identifiers.empty?
    if (record = find_by(identifiers))
      record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
    else
      new(passwords)
      nil
    end
  end
  
  def confirm!
    if unconfirmed_or_reconfirming?
      if unconfirmed_email.present?
        return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
      end
      update_columns(confirmed_at: Time.current)
    else
      false
    end
  end
  
  def confirmed?
    confirmed_at.present?
  end
  
  def confirmable_email
    if unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end
  
  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end
  
  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end
  
  def display_name_or_username
    display_name.presence || username
  end

  def follow(other_user)
    following << other_user unless self == other_user || following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    sent_follows.where(followed_id: other_user.id).exists?
  end

  def feed
    Post.includes(:user).where(user_id: following_ids).recent
  end

  def unconfirmed?
    !confirmed?
  end
  
  def reconfirming?
    unconfirmed_email.present?
  end
  
  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end
  
  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_later
  end
  
  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_later
  end
  
  private
  
  def downcase_email
    self.email = email.downcase
  end
  
  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?
    self.unconfirmed_email = unconfirmed_email.downcase
  end
end
