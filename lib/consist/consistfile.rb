# frozen_string_literal: true37236

module Consist
  class << self
    attr_accessor :files
  end

  @files = []

  class Consistfile
    include SSHKit::DSL

    def initialize(server_ip)
      @server_ip = server_ip
      consistfile = File.read(File.expand_path("Consistfile", Dir.pwd))
      instance_eval(consistfile)
    end

    def consist(&definition)
      instance_eval(&definition)
    end

    def recipe(id, &definition)
      recipe = Consist::Recipe.new(id, &definition)

      puts "Executing Recipe: #{recipe.name}"
      recipe.steps.each do |step|
        puts "Executing Step: #{step.name}"

        on("#{step.required_user}@#{@server_ip}") do
          step.perform(self)
        end
      end

      puts "Execution of #{recipe.name} has completed."
    end

    def file(id, &definition)
      return unless definition

      contents = yield

      Consist.files << {id:, contents:}
    end
  end
end
