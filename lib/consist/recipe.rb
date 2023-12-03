# frozen_string_literal: true

module Consist
  class Recipe
    def initialize(id = nil, &definition)
      @steps = []
      @id = id

      if definition
        instance_eval(&definition)
      else
        contents = Consist::Resolver.new(pwd: Dir.pwd).resolve_artifact(type: :recipe, id:)
        instance_eval(contents)
      end
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

    def steps(&definition)
      instance_eval(&definition) if definition
      @steps
    end

    def step(id, &definition)
      @steps << Step.new(id:, &definition)
    end
  end
end
