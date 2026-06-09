# frozen_string_literal: true
module Hyrax
  class XmlImportsController < ApplicationController
    def new
      @import = XmlImport.new
    end

    def create
      @import       = XmlImport.new(import_params)
      @import.batch = Batch.create(batchable: @import,
                                   creator: current_user,
                                   ids: [])
      if @import.save
        redirect_to main_app.xml_import_path(@import)
      else
        messages    = @import.errors.messages[:base].join("\n")
        flash.alert = ' Errors were found in ' \
                      "#{@import.metadata_file.file.original_filename}:" \
                      "\n#{messages}"
        redirect_to main_app.new_xml_import_path
      end
    end

    def edit
      @import = XmlImportPresenter.new(XmlImport.find(params[:id]))
    end

    def show
      @import = XmlImportPresenter.new(XmlImport.find(params[:id]))
    end

    def update
      @import = XmlImport.find(params[:id])

      if uploaded_file_ids.empty?
        flash.alert = 'No files added. Please upload files before submitting.'
        redirect_to main_app.edit_xml_import_path(@import)
      else
        result = Tufts::XmlImportSubmissionService.submit!(import: @import,
                                                           uploaded_file_ids: uploaded_file_ids)

        prepare_notices!(result)
        redirect_to main_app.xml_import_path(@import)
      end
    end

    private

    ##
    # @private
    def import_params
      params
        .require(:xml_import)
        .permit(:metadata_file)
    end

    ##
    # @private
    # @return [Array<Integer>]
    def uploaded_file_ids
      params.fetch(:uploaded_files, []).map(&:to_i)
    end

    ##
    # @private
    # @param result [Tufts::XmlImportSubmissionService::Result]
    #
    # @return [void]
    def prepare_notices!(result)
      flash.notice = added_notice(result.added_filenames) if result.added_filenames.any?

      return if result.existing_filenames.empty? && result.unmatched_filenames.empty?

      flash.alert = "".dup

      flash.alert.concat(unmatched_notice(result.unmatched_filenames)) if result.unmatched_filenames.any?
      flash.alert.concat(exists_notice(result.existing_filenames))     if result.existing_filenames.any?
    end

    ##
    # @private
    # @param added_filenames [Array<String>]
    #
    # @return [String]
    def added_notice(added_filenames)
      return "Added #{added_filenames.count} files." if added_filenames.count > 10

      "Added files: #{added_filenames.join(', ')}"
    end

    ##
    # @private
    # @param unmatched_filenames [Array<String>]
    #
    # @return [String]
    def unmatched_notice(unmatched_filenames)
      return "#{unmatched_filenames.count} files did not match." if unmatched_filenames.count > 10

      "Files did not match: #{unmatched_filenames.join(', ')};\n"
    end

    ##
    # @private
    # @param existing_filenames [Array<String>]
    #
    # @return [String]
    def exists_notice(existing_filenames)
      "Files already uploaded, new version is ignored: #{existing_filenames.join(', ')}"
    end
  end
end
