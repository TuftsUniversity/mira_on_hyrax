# frozen_string_literal: true
module Tufts
  module HasTranscriptForm
    def transcript_files(type)
      transcript_files = file_presenters.select { |file| transcript?(file, type) }
      Hash[transcript_files.map { |file| [file.to_s, file.id] }]
    end

    def transcript?(file, type)
      if type == "Video" || type == "Generic Object"
        ['xml', 'plain', 'vtt'].any? { |type| file.mime_type&.include?(type) }
      else
        file.mime_type&.include?('xml')
      end
    end
  end
end
