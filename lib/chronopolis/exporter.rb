# frozen_string_literal: true
class Chronopolis::Exporter
  def initialize
    @logger = Logger.new('log/chronopolis.log')
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def perform_export(pid, include_metadata = true)
    @logger.info "PROCESSING PID : #{pid}"
    obj = ActiveFedora::Base.find(pid)

    steward = steward_from_object(obj)

    collection = collection_from_object(obj)

    @logger.info "Collection for #{pid} is #{collection}"

    # mkdir for object

    obj_dir = obj.id + "_" + obj.title.first
    obj_dir = obj_dir.truncate(255)
    obj_dir = sanitize_filename(obj_dir)

    FileUtils.mkdir_p File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir)

    # mkdirs for filesets
    obj.file_sets.each do |file_set|
      target_filename = file_set.id + "_" + file_set.title.first
      target_filename = target_filename.truncate(255)
      target_filename = sanitize_filename(target_filename)
      FileUtils.mkdir_p File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename)
      target_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename, target_filename)
      metadata_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename, "technical_metadata.json")

      target_file = check_for_file_extension(target_file)
      record = File.new target_file, 'wb'

      @logger.info "Writing fileset to #{target_file}"

      record.write file_set.original_file.content
      record.flush
      record.close

      next unless include_metadata
      json = JSON.parse(file_set.characterization_proxy.metadata.attributes.to_json)
      json = JSON.pretty_generate(json)
      metadata = File.new metadata_file, "w"

      @logger.info "Writing metadata to #{metadata_file}"

      metadata.write json
      metadata.flush
      metadata.close
    end

    # write out metadata
    if include_metadata
      json = JSON.parse(obj.to_json)
      json = JSON.pretty_generate(json)
      metadata_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, "metadata.json")
      metadata = File.new metadata_file, "w"

      @logger.info "Writing metadata to #{metadata_file}"

      metadata.write json
      metadata.flush
      metadata.close
    end
  rescue ActiveFedora::ObjectNotFoundError
    @logger.error "ERROR Pid not found #{pid}"
  rescue Ldp::Gone
    @logger.error "ERROR Pid not found #{pid}"
  end

  private

  def check_for_file_extension(target_file)
    if File.extname(target_file) == ""
      mime = file_set.mime_type
      mime_string = if mime.nil? || mime == ""
                      ""
                    else
                      "." + mime.split('/')[1]
                    end
      target_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename, target_filename + mime_string)
    end

    target_file
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def collection_from_object(obj)
    # get collection for object
    collections = obj.member_of_collections

    return "uncollected" if collections.blank?

    collection_titles = []
    collection_ids = []

    collections.each do |collection_inner|
      collection_titles << collection_inner.title.first
      collection_ids << collection_inner.id
    end

    index = collection_titles.index("Collection Descriptions")
    saved_index = 0
    if !index.nil? && collection_titles.length > 1
      collection_titles.delete("Collection Descriptions")
      saved_index = index.positive? ? 0 : 1
    end
    @logger.info "COL TITLES : #{collection_titles}"

    index = collection_titles.index("Electronic Theses and Dissertations")
    collection = if index.nil?
                   collections[saved_index].id + "_" + collections[saved_index].title.first
                 else
                   collection_ids[index] + "_" + "Electronic Theses and Dissertations"
                 end

    collection = collection.truncate(255)
    sanitize_filename(collection)
  end

  def steward_from_object(obj)
    # get steward for top directory
    steward = obj.steward
    steward = steward.presence || "no_steward"

    @logger.info "Steward for #{obj.id} is #{steward}"

    sanitize_filename(steward)
  end

  def sanitize_filename(filename)
    # Split the name when finding a period which is preceded by some
    # character, and is followed by some character other than a period,
    # if there is no following period that is followed by something
    # other than a period (yeah, confusing, I know)
    fn = filename.split(/(?<=.)\.(?=[^.])(?!.*\.[^.])/m)

    # We now have one or two parts (depending on whether we could find
    # a suitable period). For each of these parts, replace any unwanted
    # sequence of characters with an underscore
    fn.map! { |s| s.gsub(/[^a-z0-9\-]+/i, '_') }

    # Finally, join the parts with a period and return the result
    fn.join '.'
  end
end
