# frozen_string_literal: true

require "erb"

module Consist
  class Step
    include SSHKit::DSL

    def initialize(id:, &definition)
      @commands = []
      @id = id
      @required_user = :root

      if definition
        instance_eval(&definition)
      else
        contents = Consist::Resolver.new(pwd: Dir.pwd).resolve_artifact(type: :step, id:)
        instance_eval(contents)
      end
    end

    def id(id = nil)
      @id = id if id
      @id
    end

    def name(name = nil)
      @name = name if name
      @name
    end

    def required_user(user = nil)
      @required_user = user if user
      @required_user
    end

    def shell(message = "", params: {})
      return unless block_given?

      command = yield
      commands = command.split(/(?<!\\)\n/).select { !_1.start_with?("#") }.compact

      @commands << {message:, type: :exec, commands:, params:}
    end

    def mutate_file(mode:, target_file:, match:, target_string:, delim: "/", message: "")
      @commands << {type: :mutate, mode:, message:, match:, target_file:, delim:, target_string:}
    end

    def upload_file(local_file:, remote_path:, message: "")
      @commands << {message:, type: :upload, local_file:, remote_path:}
    end

    def check(status:, path: nil, file: nil, message: "", &block)
      @commands << {type: :check, message:, status:, file:, path:, block: -> { instance_eval(&block) }}
    end

    def perform(executor)
      @commands.each do |command|
        banner(command[:message]) unless command[:message].empty?

        execable = Object.const_get("Consist::Commands::#{command[:type].capitalize}").new(command)
        executor.as @required_user do
          execable.perform!(executor)
        end
      end
    end

    private

    def banner(message)
      return if message.empty?

      msg = "********* #{message} ********"
      puts "*" * msg.length
      puts msg
      puts "*" * msg.length
    end
  end
end
