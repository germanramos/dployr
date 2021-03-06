require 'net/scp'

module Dployr
  module Scripts
    class Scp

      def initialize(ip, host, username, private_key_path, script)
        begin
          puts "Connecting to #{host} (SCP)...".yellow
          Net::SCP.start(ip, username, :keys => [private_key_path]) do |scp|
            source = script["source"]
            target = script["target"]
            puts "Copying #{source} -> #{target}".yellow
            scp.upload(source, target, :recursive => true, :preserve => true)
          end
        rescue => e
          raise "Cannot copy to remote: #{e}"
        end
      end

    end
  end
end
