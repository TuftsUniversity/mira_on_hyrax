# frozen_string_literal: true
class CharacterizeJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Characterizes the file at 'filepath' if available, otherwise, pulls a copy from the repository
  # and runs characterization on that file.
  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath)
    run_local_characterization_services(file_set, filepath)
    Rails.logger.debug "Ran characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)
    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end

  private

  def run_local_characterization_services(file_set, source)
    Tufts::CharacterizationService.run(file_set.characterization_proxy, source)
    PdfPagesJob.perform_later(file_set) if file_set.mime_type == 'application/pdf'
    Rails.logger.debug "Ran Tufts::CharacterizationService on #{file_set.id} (#{file_set.mime_type})"
  end
end
