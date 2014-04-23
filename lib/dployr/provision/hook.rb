require 'logger'
require 'dployr/utils'
require 'colorize'

module Dployr
  module Provision
    class Hook

      include Dployr::Utils

      def initialize(instance, stage)
        @log = Logger.new STDOUT
        @instance = instance
        @stage = stage
      end

      private

      def run
        attrs = @instance[:attributes]
        host = attrs["name"]
        username = attrs["username"]
        private_key_path = attrs["private_key_path"]

        puts "STAGE '#{stage}':".yellow
        @instance[:scripts][stage].each do |script|
          if script["target"]
            Dployr::Provision::Scp.new host, username, private_key_path, script
          else
            Dployr::Provision::Shell.new host, username, private_key_path, script
          end
        end
      end
    end
  end
end
