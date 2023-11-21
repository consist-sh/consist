# frozen_string_literal: true

module Consist
  class Step
    def initialize(&block)
      instance_eval(&block)
    end

    def name(name = nil)
      @name = name if name
      @name
    end

    def required_user(user = nil)
      @required_user = user if user
      @required_user
    end

    def shell
      @commands = yield if block_given?
      @commands
    end
  end
end
