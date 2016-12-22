require 'bcrypt'
class User < ActiveRecord::Base
  include BCrypt

  validates :username, :email, :password_hash, presence: true
  validates :email, uniqueness: true

  has_many :listings, class_name: "Item", foreign_key: :seller_id
  has_many :bids, foreign_key: :bidder_id

  def self.authenticate(credentials)
    user = User.find_by(email: credentials[:email])
    if user && user.password == credentials[:password]
      user
    end
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.create_with_auth_and_hash(authentication,auth_hash)
    create! do |u|
      u.password = Time.now.to_i.to_s(36)
      u.name = auth_hash["info"]["name"]
      u.email = auth_hash["extra"]["raw_info"]["email"]
      u.authentications<<(authentication)
    end
  end

  def fb_token
    x = self.authentications.where(:provider => :facebook).first
    return x.token unless x.nil?
  end

  def password_optional?
    true
  end

  enum role: [:buyer, :seller, :administrator, :super_admin]
end
