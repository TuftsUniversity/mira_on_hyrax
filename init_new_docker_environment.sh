bundle exec rails hyrax:default_admin_set:create
bundle exec rails hyrax:default_collection_types:create
bundle exec rails hyrax:workflow:load
bundle exec rake db:seed
bundle exec rake tufts:create_admin
