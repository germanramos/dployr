require 'dployr/configuration'
require 'dployr/config/file_utils'

module Dployr

  module_function

  def configure(attributes = {})
    dployr = Init::instance
    yield dployr if block_given?
  end

  def config
    dployr = Init::instance
    dployr.config if dployr
  end

  def load(file_path)
    if Dployr::Config::FileUtils.yaml_file? file_path
      Dployr::Config::FileUtils.read_yaml file_path
    else
      load file_path
    end
  end

  class Init

    include Dployr::Config::FileUtils

    attr_reader :file_path, :config

    @@instance = nil

    def initialize(attributes = {})
      @@instance = self
      @attributes = attributes
      @config = Dployr::Configuration.new
      @file_path = discover
      load_file @file_path
    end

    def self.instance
      @@instance
    end

    private

    def load_file(file_path)
      if file_path.is_a? String
        if yaml_file? file_path
          load_yaml file_path
        else
          load file_path
        end
      end
    end

    def load_yaml(file_path)
      config = read_yaml file_path
      if config.is_a? Hash
        config.each do |name, config|
          if key == 'default'
            @config.set_default value
          else
            @config.add_instance name, value
          end
        end
      end
    end

  end
end
