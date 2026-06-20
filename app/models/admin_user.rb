class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable and :timeoutable
  devise :database_authenticatable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:authentik]

  def self.ransackable_attributes(*)
    %w[email]
  end

  # Finds an existing admin by SSO uid or email, or creates a new one.
  # No password is set for SSO-only accounts; database_authenticatable
  # login simply won't succeed for them.
  def self.from_omniauth(auth)
    find_by(provider: auth.provider, uid: auth.uid) ||
      find_by(email: auth.info.email)&.tap { |u| u.update!(provider: auth.provider, uid: auth.uid) } ||
      create!(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0, 20]
      )
  end
end
