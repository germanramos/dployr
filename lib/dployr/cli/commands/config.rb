require 'logger'
require 'dployr'
require 'dployr/utils'

module Dployr
  module CLI
    class Config

      include Dployr::Utils

      def initialize(options)
        @options = options
        @name = options[:name]
        @log = Logger.new STDOUT
        @attributes = parse_attributes @options[:attributes]

        puts @options
        begin
          create
          render_file
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      def create
        begin
          @dployr = Dployr::Init.new @attributes
        rescue Exception => e
          raise "Cannot load the config: #{e}"
        end
      end

      def render_file
        raise "Dployrfile was not found" if @dployr.file_path.nil?
        raise "Configuration is missing" unless @dployr.config.exists?
        begin
          if @name
            config = @dployr.config.get_config @name, @attributes
          else
            puts @attributes
            config = @dployr.config.get_config_all @attributes
          end
          unless config.nil?
            puts config.to_yaml
          else
            @log.info "Missing configuration data"
          end
        rescue Exception => e
          raise "Cannot generate the config: #{e}"
        end
      end

      def parse_attributes(attributes)
        if attributes.is_a? String
          if @options[:attributes][0] == '-'
            parse_flags attributes
          else
            parse_matrix attributes
          end
        end
      end

    end
  end
end
