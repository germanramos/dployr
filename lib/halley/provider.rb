require 'fog'

module Halley
  class Provider

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

  end
end
