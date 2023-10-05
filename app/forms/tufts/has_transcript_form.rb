# frozen_string_literal: true
module Tufts
  module HasTranscriptForm
    def transcript_files(type)
      transcript_files = file_presenters.select { |file| transcript?(file, type) }
      Hash[transcript_files.map { |file| [file.to_s, file.id] }]
    end

    def transcript?(file, object_type)
      if object_type == "Video" || object_type == "Generic Object"
        ['xml', 'plain', 'vtt'].any? { |mime_type| file.mime_type&.include?(mime_type) }
      else
        file.mime_type&.include?('xml')
      end
    end
  end
end
