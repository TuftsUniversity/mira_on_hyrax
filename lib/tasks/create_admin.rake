# frozen_string_literal: true
require 'rake'
require 'securerandom'

namespace :tufts do
  desc "Create admin user"
  task create_admin: :environment do
    mike = {
      email: 'mike.korcynski@tufts.edu',
      username: 'mkorcy01',
      password: SecureRandom.hex
    }

    brian = {
      email: 'brian.goodmoni@tufts.edu',
      username: 'bgoodm01',
      password: SecureRandom.hex
    }
    users = []
    users.push(mike)
    users.push(brian)

    users.each do |user|
      u = User.create(
        email: user[:email],
        username: user[:username],
        password: user[:password]

      )
      u.add_role('admin')
      u.save
    end
  end
end
