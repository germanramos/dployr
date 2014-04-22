require 'logger'
require 'dployr'
require 'dployr/utils'
require 'json'
require 'net/ssh'
require 'colorize'

module Dployr
  module Provision
    class Shell

      include Dployr::Utils

      def initialize(host, username, private_key_path, script)
      
        begin
          @log = Logger.new STDOUT
          puts "Connecting to #{host} (SSH)...".yellow
          Net::SSH.start(host, username, :keys => [private_key_path]) do |ssh|
            @host = host
            command = script["path"]
            arguments = script["args"]
            puts "Running remote script '#{command} #{arguments}'".yellow
            result = ssh_exec!(ssh, command)
            #puts result.inspect
            if result[:exit_code] > 0
              raise "Exit code #{result[:exit_code]} when running script '#{command} #{arguments}'".yellow
            else
              puts "Remote script '#{command} #{arguments}' finished succesfully".yellow
            end
          end
          
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end

      # http://craiccomputing.blogspot.com.es/2010/08/printing-colored-text-in-unix-terminals.html
      def ssh_exec!(ssh, command)
        stdout_data = ""
        stderr_data = ""
        exit_code = nil
        exit_signal = nil
        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            unless success
              abort "FAILED: couldn't execute command (ssh.channel.exec)"
            end
            channel.on_data do |ch,data|
              stdout_data+=data
              print "[#{@host}] #{data}".green
            end
      
            channel.on_extended_data do |ch,type,data|
              stderr_data+=data
              print "[#{@host}] #{data}".red
            end
      
            channel.on_request("exit-status") do |ch,data|
              exit_code = data.read_long
            end
      
            channel.on_request("exit-signal") do |ch, data|
              exit_signal = data.read_long
            end
          end
        end
        ssh.loop
        #puts "\033[0m"
        {
          stdout_data: stdout_data,
          stderr_data: stderr_data, 
          exit_code: exit_code,
          exit_signal: exit_signal
        }
      end
    end
  end
end