# frozen_string_literal: true

module Consist
  class StreamOutputInteractionHandler
    def initialize(log_level = :info)
      @log_level = log_level
    end

    def on_data(_command, _stream_name, data, _channel)
      log(data)
    end

    private

    def log(message)
      SSHKit.config.output.send(@log_level, message) unless @log_level.nil?
    end
  end

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
          puts "--> #{step.shell}"

          on("#{step.required_user}@#{server_ip}") do
            as step.required_user do
              execute step.shell.to_s, interaction_handler: StreamOutputInteractionHandler.new
            end
          end
        end

        puts "Execution of #{recipe.name} has completed."
      end
    end
  end
end
