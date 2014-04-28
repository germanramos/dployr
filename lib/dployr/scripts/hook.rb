require 'logger'
require 'dployr/utils'
require 'colorize'

module Dployr
  module Scripts
    class Hook

      include Dployr::Utils

      def initialize(ip, instance, stage)
        @log = Logger.new STDOUT
        @ip = ip
        @instance = instance
        @stage = stage
        run
      end

      private

      def run
        attrs = @instance[:attributes]
        host = attrs["name"]
        username = attrs["username"]
        private_key_path = attrs["private_key_path"]

        puts "STAGE '#{@stage}':".yellow
        @instance[:scripts][@stage].each do |script|
          if script["target"]
            Dployr::Scripts::Scp.new @ip, host, username, private_key_path, script
          elsif script["remote_path"]
            Dployr::Scripts::Shell.new @ip, host, username, private_key_path, script
          elsif script["local_path"]
            Dployr::Scripts::Local_Shell.new script
          end
        end
      end
    end
  end
end
