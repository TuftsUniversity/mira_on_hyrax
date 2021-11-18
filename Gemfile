source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
gem 'active-fedora'
gem 'activejob-uniqueness', '0.2.0', require: 'active_job/uniqueness/sidekiq_patch'
gem 'chunky_png'
gem 'dotenv-rails'
gem 'exiftool_vendored'
# gem 'fedora-migrate', path: '../fedora-migrate'
gem 'fastimage'
gem 'hydra-role-management'
gem 'hyrax', '2.8.0'
gem 'mimemagic', '0.3.10'
gem 'nokogiri', '>=1.8.2' # 1.8.2 fixes security issue https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-15412
gem 'okcomputer'
gem 'pdf-reader'
gem 'rack', '2.0.8'
gem 'rack-protection', '~> 2.0.1' # 2.0.1 fixes security issue https://github.com/sinatra/sinatra/pull/1379
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2'
gem 'rmagick', '2.16.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'blacklight', '~> 6.20.0'
gem 'blacklight_advanced_search'
gem 'whenever', require: false

gem 'tufts-curation', git: 'https://github.com/TuftsUniversity/tufts-curation', tag: 'v1.2.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'launchy'
  gem 'pry'
  gem 'term-ansicolor'
end

group :development do
  # Include deployments scripting only in development environment
  gem 'capistrano', '~> 3.9'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.3'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'active_job_status', '~> 1.2.1'
gem 'devise-guests', '~> 0.6'
gem 'devise_ldap_authenticatable'
gem 'handle-system', git: 'https://github.com/TuftsUniversity/handle.git'
gem 'ladle'
gem 'mysql2'
gem 'react-rails'
gem 'rsolr', '>= 1.0'
gem 'sanitize', '5.0.0' # Upgrade further
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sidekiq-limit_fetch'

group :production do
  gem 'passenger'
  gem 'therubyracer'
end

group :development, :test do
  gem 'bixby'
  gem 'capybara'
  gem 'capybara-maleficent', require: false
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'fcrepo_wrapper'
  gem 'ffaker'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.5.1'
  gem 'simplecov'
  gem 'simplecov-lcov', '~> 0.8.0'
  gem 'solr_wrapper', '>= 0.3'
end

# github security updates list
gem "devise", ">= 4.6.0"
gem "rubyzip", ">= 1.2.2"
