require 'logger'
require 'dployr/utils'
require 'dployr/compute/aws'
require 'colorize'

module Dployr
  module Provision
    class Provision

      include Dployr::Utils

      def initialize(instance, options)
        begin
          @log = Logger.new STDOUT
          if options[:provider] == "aws"
            @name = instance[:attributes]["name"]
            @region = options[:region]
            
            puts "Connecting to AWS...".yellow
            aws = Dployr::Compute::AWS.new(@region)
            
            puts "Looking for #{@name} in #{@region}...".yellow
            @ip  = aws.get_ip(@name)
            
            if @ip
              puts "#{@name} found with IP #{@ip}".yellow
            else
              raise "#{@name} not found"
            end
          else
            raise "Unsopported provider #{options[:provider]}"
          end
          
          if instance[:scripts]["pre-provision"]
            Dployr::Provision::Hook.new @ip, instance, "pre-provision"
          end
          if instance[:scripts]["provision"]
            Dployr::Provision::Hook.new @ip, instance, "provision"
          end
          if instance[:scripts]["post-provision"]
            Dployr::Provision::Hook.new @ip, instance, "post-provision"
          end
        rescue Exception => e
          @log.error e
          Process.exit! false
        end
      end
    end
  end
end
