# frozen_string_literal: true

require "buk_extract_i18n/version"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "html_extractor"   => "HTMLExtractor",
)
loader.setup # ready!

module BukExtractI18n
  class << self
    attr_accessor :strip_path, :ignore_hash_keys, :ignore_functions, :ignorelist, :html_fields_with_plaintext
  end

  self.strip_path = %r{^app/}

  # ignore for .rb files: ignore those file types
  self.ignore_hash_keys = %w[
    class_name foreign_key join_table association_foreign_key key anchor format class type country_namespace table_id
  ]
  self.ignore_functions = %w[
    where order group select sql t slice get_files_history strftime block address_error_message new dig find_by not
    starts_with? include? eql? load_and_authorize_resource concat casecmp include? error
  ]
  self.ignorelist = [
    '_',
    '::',
    %r{^/},
    %r{==\s*['"].+['"]}
  ]
  self.html_fields_with_plaintext = %w[title placeholder alt aria-label modal-title anchor]

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.key(string, length: 25)
    if BukExtractI18n.configuration.use_open_ai
      text_processor = BukExtractI18n::Openai::TextProcessor.new
      text_processor.key_summary(string)
    else
      string.strip.
        unicode_normalize(:nfkd).gsub(/(\p{Letter})\p{Mark}+/, '\\1').
        gsub(/\W+/, '_').downcase[0..length].
        gsub(/_+$|^_+/, '')
    end
  end

  def self.file_key(path)
    path.gsub(strip_path, '').
      gsub(%r{^/|/$}, '').
      gsub(/\.(rb|erb)$/, '').
      gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').
      gsub('/_', '.').
      gsub('/', '.').
      tr("-", "_").downcase
  end
end

require 'buk_extract_i18n/file_processor'
