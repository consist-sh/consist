# frozen_string_literal: true37236

module Consist
  class << self
    attr_accessor :files, :config, :consist_dir
  end

  @files = []
  @config = {}
  @consist_dir = ""

  class Consistfile
    include SSHKit::DSL

    def initialize(server_ip, specified_step:, consist_dir:, consistfile:)
      @server_ip = server_ip
      @specified_step = specified_step
      Consist.consist_dir = consist_dir || ".consist"

      consistfile_path = if consistfile
        File.expand_path(consistfile, Dir.pwd)
      else
        File.expand_path("Consistfile", Dir.pwd)
      end

      consistfile_contents = File.read(consistfile_path)
      instance_eval(consistfile_contents)
    end

    def consist(&definition)
      instance_eval(&definition)
    end

    def recipe(id, &definition)
      recipe = Consist::Recipe.new(id, &definition)
      puts "Executing Recipe: #{recipe.name}"

      if @specified_step.nil?
        recipe.steps.each { exec_step(_1) }
      else
        puts "Specific step targeted: #{@specified_step.to_sym}"
        specified_step, *_rest = recipe.steps.select { _1.id === @specified_step.to_sym }
        raise "Step with id #{@specified_step.to_sym} not found." unless specified_step

        exec_step(specified_step)
      end

      puts "Execution of #{recipe.name} has completed."
    end

    def file(id, &definition)
      if definition
        contents = yield
      else
        file_contents = Consist::Resolver.new(pwd: Dir.pwd).resolve_artifact(type: :file, id:)
        contents = file_contents
      end

      Consist.files << {id:, contents:}
    end

    def config(id, val)
      Consist.config[id] = val
    end

    private

    def exec_step(specified_step)
      puts "Executing Step: #{specified_step.name}"

      on("#{specified_step.required_user}@#{@server_ip}") do
        specified_step.perform(self)
      end
    end
  end
end
