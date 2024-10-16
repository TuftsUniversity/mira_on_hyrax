# frozen_string_literal: true
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
Hyrax::FileSetIndexer.class_eval do
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['hasRelatedMediaFragment_ssim'] = object.representative_id
      solr_doc['hasRelatedImage_ssim'] = object.thumbnail_id
      # Label is the actual file name. It's not editable by the user.
      solr_doc['label_tesim'] = object.label
      solr_doc['label_ssi']   = object.label
      solr_doc['file_format_tesim'] = file_format
      solr_doc['file_format_sim']   = file_format
      solr_doc['file_size_lts'] = object.file_size[0]
      solr_doc['all_text_timv'] = object.extracted_text.content if object.extracted_text.present?
      solr_doc['height_is'] = Integer(object.height.first) if object.height.present?
      solr_doc['width_is']  = Integer(object.width.first) if object.width.present?
      solr_doc['visibility_ssi'] = object.visibility
      solr_doc['mime_type_ssi']  = object.mime_type
      # Index the Fedora-generated SHA1 digest to create a linkage between
      # files on disk (in fcrepo.binary-store-path) and objects in the repository.
      solr_doc['digest_ssim'] = digest_from_content
      solr_doc['page_count_tesim']        = object.page_count
      solr_doc['file_title_tesim']        = object.file_title
      solr_doc['duration_tesim']          = object.duration
      solr_doc['sample_rate_tesim']       = object.sample_rate
      solr_doc['original_checksum_tesim'] = object.original_checksum

      # Tufts Technical Metadata
      solr_doc['bits_per_sample_tesim'] = object.bits_per_sample
      solr_doc['resolution_unit_tesim'] = object.resolution_unit
      solr_doc['samples_per_pixel_tesim'] = object.samples_per_pixel
      solr_doc['x_resolution_tesim'] = object.x_resolution
      solr_doc['y_resolution_tesim'] = object.y_resolution
      solr_doc['file_date_created_tesim'] = object.characterization_proxy.date_created
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
