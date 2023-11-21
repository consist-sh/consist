# frozen_string_literal: true

module Consist
  class Recipes
    include SSHKit::DSL

    def initialize(server_ip)
      recipe_directory = File.expand_path("../recipes", __dir__)
      recipes = Dir[File.join(recipe_directory, "*.rb")]

      recipes.each do |recipe_file|
        recipe_content = File.read(recipe_file)
        recipe = Recipe.new { instance_eval(recipe_content) }

        puts "Executing Recipe: #{recipe.name}"
        recipe.steps.each do |step|
          puts "Executing Step: #{step.name}"

          on("#{step.required_user}@#{server_ip}") do
            as step.required_user do
              step.perform(self)
            end
          end
        end

        puts "Execution of #{recipe.name} has completed."
      end
    end
  end
end
