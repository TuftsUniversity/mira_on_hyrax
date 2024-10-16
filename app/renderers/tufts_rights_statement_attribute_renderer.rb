# frozen_string_literal: true
# This is used by PresentsAttributes to show licenses
#   e.g.: presenter.attribute_to_html(:rights_statement, render_as: :rights_statement)
# We are overriding the Hyrax RightsStatementAttributeRenderer because it crashes when rights_statement is invalid
# See https://github.com/samvera/hyrax/issues/2323 for bug report
class TuftsRightsStatementAttributeRenderer < Hyrax::Renderers::RightsStatementAttributeRenderer
  private

  ##
  # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
  # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
  def attribute_value_to_html(value)
    return if value == ""
    begin
      parsed_uri = URI.parse(value)
    rescue
      nil
    end
    if parsed_uri.nil?
      ERB::Util.h(value)
    else
      %(<a href=#{ERB::Util.h(value)} target="_blank">#{Hyrax.config.rights_statement_service_class.new.label(value)}</a>)
    end
  rescue => exception
    Rails.logger.error("Could not render rights statement #{value}: #{exception}")
  end
end
