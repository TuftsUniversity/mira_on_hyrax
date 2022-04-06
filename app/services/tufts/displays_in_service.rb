# frozen_string_literal: true
module Tufts
  module DisplaysInService
    mattr_accessor :authority
    self.authority = Qa::Authorities::Local.subauthority_for('displays')

    def self.select_options
      authority.all.map do |element|
        [element[:label], element[:id]]
      end
    end

    def self.label(id)
      authority.find(id).fetch('term')
    end
  end
end
