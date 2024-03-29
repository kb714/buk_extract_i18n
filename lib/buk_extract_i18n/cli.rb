# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require 'optparse'
require 'buk_extract_i18n'
require 'buk_extract_i18n/file_processor'
require 'buk_extract_i18n/version'
require 'open-uri'

module BukExtractI18n
  # Cli Class
  class CLI
    def initialize
      @options = {}
      ARGV << '-h' if ARGV.empty?
      OptionParser.new do |opts|
        opts.banner = "Usage: buk-extract-i18n -l <locale> -w <target-yml> [path*]"

        opts.on('--version', 'Print version number') do
          puts BukExtractI18n::VERSION
          exit 1
        end

        opts.on('-lLOCALE', '--locale=LOCALE', 'default locale for extraction (Default = es)') do |f|
          @options[:locale] = f || 'es'
        end

        opts.on('-nNAMESPACE', '--namespace=NAMESPACE', 'Locale base key to wrap locations in') do |f|
          @options[:namespace] = f
        end

        opts.on('-r', '--slim-relative', 'When activated, will use relative keys like t(".title")') do |f|
          @options[:relative] = f
        end

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit 1
        end
      end.parse!

      @options[:locale] ||= 'es'
      @files = ARGV
    end

    def run
      paths = @files.empty? ? [] : @files
      paths.each do |path|
        if File.directory?(path)
          glob_path = File.join(path, '**', '*.rb')
          Dir.glob(glob_path) do |file_path|
            process_file file_path
          end
        else
          process_file path
        end
      end
    end

    def process_file(file_path)
      puts "Processing: #{file_path}"
      BukExtractI18n::FileProcessor.new(
        file_path: file_path,
        locale: @options[:locale],
        options: @options
      ).run
    end
  end
end
