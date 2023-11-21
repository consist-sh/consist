# frozen_string_literal: true

module Consist
  class Recipe
    def initialize(_id = nil, &definition)
      @steps = []
      instance_eval(&definition)
    end

    def name(name = nil)
      @name = name if name
      @name
    end

    def description(description = nil)
      @description = description if description
      @description
    end

    def user(user = nil)
      @user = user if @user
      @user
    end

    def steps(&block)
      instance_eval(&block) if block
      @steps
    end

    def step(step_name, &block)
      if block
        @steps << Step.new(id: step_name, &block)
        return
      end

      target_path = File.join("../../", "steps", step_name.to_s, "step.rb")
      step_path = File.expand_path(target_path, __FILE__)
      step_content = File.read(step_path)
      @steps << Step.new(id: step_name) { instance_eval(step_content) }
    end
  end
end
