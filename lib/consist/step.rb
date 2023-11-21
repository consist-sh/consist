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

  class Step
    include SSHKit::DSL

    def initialize(&block)
      @commands = []
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

    def shell(message = "")
      return unless block_given?

      command = yield

      @commands << {message:, commands: command.split('\n').compact}
    end

    private

    def exec(executor, command)
      executor.send(:execute, command, interaction_handler: StreamOutputInteractionHandler.new)
    end

    def banner(message)
      return if message.empty?

      msg = "********* #{message} ********"
      puts "*" * msg.length
      puts msg
      puts "*" * msg.length
    end

    def perform(executor)
      @commands.each do |command|
        banner(command[:message]) unless command[:message].empty?

        command[:commands].each do |cmd|
          exec(executor, cmd)
        end
      end
    end
  end
end
