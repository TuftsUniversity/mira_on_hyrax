bundle exec rake hyrax:default_admin_set:create
bundle exec rake hyrax:default_collection_types:create
bundle exec rake tufts:fix_collection_type_labels
bundle exec rake hyrax:workflow:load
bundle exec rake db:seed
bundle exec rake tufts:create_admin
