##
# A job to process imported records and files
class ImportJob < BatchableJob
  def perform(import, file, id = nil)
    Tufts::ImportService
      .import_object!(file: file, import: import, object_id: id)
  end
end