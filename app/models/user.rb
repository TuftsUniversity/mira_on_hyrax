# frozen_string_literal: true
class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  if Rails.env.development? || Rails.env.test?
    devise :ldap_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
  else
    devise_modules = [:omniauthable, :rememberable, :trackable, omniauth_providers: [:shibboleth], authentication_keys: [:uid]]
    devise(*devise_modules)
  end

  ##
  # @see https://github.com/samvera/hyrax/pull/2340
  def name
    display_name || user_key
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    display_name || user_key
  end

  def add_role(name)
    role = Role.find_by(name: name)
    role = Role.create(name: name) if role.nil?
    role.users << self
    role.save
    reload
  end

  def remove_role(name)
    role = Role.find_by(name: name)
    role.users.delete(self) if role&.users && role.users.include?(self)
    reload
  end

  # Mailboxer (the notification system) needs the User object to respond to this method
  # in order to send emails
  def mailboxer_email(_object)
    email
  end

  # Hyrax 2.0 expects this to be set for the user
  def preferred_locale
    'en'
  end

  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(username, "mail").first
    self.display_name = Devise::LDAP::Adapter.get_ldap_param(username, "tuftsEduDisplayNameLF").first
  end

  # allow omniauth (including shibboleth) logins
  #   this will create a local user based on an omniauth/shib login
  #   if they haven't logged in before
  def self.from_omniauth(auth)
    user = find_by(username: auth[:uid])
    if user.nil?
      user = User.create(
        email: auth[:mail],
        username: auth[:uid],
        display_name: auth[:name]
      )
    else
      user.display_name = auth[:name]
      user.username = auth[:uid]
      user.email = auth[:mail]
      user.save
    end
    user
  end
end

# Override a Hyrax class that expects to create system users with passwords
module Hyrax::User
  module ClassMethods
    def find_or_create_system_user(user_key)
      u = ::User.find_or_create_by(username: user_key)
      u.display_name = user_key
      u.email = "#{user_key}@example.com"
      u.password = ('a'..'z').to_a.shuffle(random: Random.new).join
      u.save
      u
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
