# frozen_string_literal: true

module Consist
  class Recipe
    def initialize(&definition)
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

    def step(step_name)
      step_file = "#{step_name}.rb" # Assuming step definition in separate file
      step_path = File.expand_path(File.join("../../", "steps", step_file), __FILE__)
      step_content = File.read(step_path)
      @steps << Step.new { instance_eval(step_content) }
    end
  end
end
