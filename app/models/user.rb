class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2, :twitter]

  def self.from_omniauth(access_token)
    data = access_token
    user = where("#{data.provider.to_s}_uid".to_sym => data.uid).first_or_initialize

    if user.new_record? && ['facebook', 'google_oauth2'].include?(data.provider.to_s)
      user = where(email: data.info.email).first_or_initialize
    end

    user.email    = user.email.present? ? user.email : (data.info.email || "#{data.info.name.parameterize}@email.com")
    user.password = '123456' if user.encrypted_password.blank?
    user.connect_provider(data)
    user
	end

  def connect_provider(auth)
    if auth.provider.to_s == 'twitter'
      self.twitter_uid = auth.uid
    elsif auth.provider.to_s == 'facebook'
      self.facebook_uid = auth.uid
    elsif auth.provider.to_s == 'google_oauth2'
      self.google_oauth2_uid = auth.uid
    end

    self.save
  end
end
