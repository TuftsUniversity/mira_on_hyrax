# frozen_string_literal: true
namespace :tufts do
  task ci: ['tufts:rubocop', 'tufts:spec']
end
