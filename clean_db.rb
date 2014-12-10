require 'yaml'
require 'logging'

class Cleaner
  ROOT = File.dirname __FILE__
  CONFIG_PATH = File.join ROOT, 'config.yml'
  ENVIRONMENTS = ['test', 'production']
  DEFAULT_ENVIRONMENT = 'test'
  LOGS_PATH = File.join ROOT, 'logs'

  def initialize env
    @@env = ENVIRONMENTS.include? env ? env : DEFAULT_ENVIRONMENT
    STDOUT.puts "Run in #{ @env } mode"

    require File.join(ROOT, 'src', 'settings')

    configure_logger
  end

  def launch_factory
    Factory.new.launch
  end

  def self.logger
    @@logger
  end

  def self.env
    @@env
  end

  def results
    @results
  end

  private

  def configure_logger
    @@logger = Logging.logger('cleaner_logger')
    @@logger.add_appenders Logging.appenders.stdout if Settings.log.stream.stdout
    Settings.log.files.each do |file_name|
      path_to_file = File.join LOGS_PATH, file_name
      begin
        @@logger.add_appenders Logging.appenders.file(path_to_file)
        STDOUT.puts "Logs will be written to the file: #{ path_to_file }"
      rescue
        STDOUT.puts "Problems with log file path specified in configs: #{ path_to_file }\nLogs will not be written to this file"
      end
    end if Settings.log.files
  end
end

cleaner = Cleaner.new :test
cleaner.launch_factory

Cleaner.logger.log "Finished successfully.\nTotal rows checked: #{ cleaner.results[:total] }\nDeleted: #{ cleaner.results[:deleted] }"
