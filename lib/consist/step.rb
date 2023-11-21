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

    def initialize(id:, &block)
      @commands = []
      @id = id
      @required_user = :root
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

      @commands << {message:, type: :exec, commands: command.split('\n').compact}
    end

    def upload_file(message:, local_file:, remote_path:)
      @commands << {message:, type: :upload, local_file:, remote_path:}
    end

    def perform(executor)
      @commands.each do |command|
        banner(command[:message]) unless command[:message].empty?

        case command[:type]
        when :exec
          command[:commands].each { exec(executor, _1) }
        when :upload
          if command[:local_file].class == Symbol
            puts "---> Uploading defined file #{command[:local_file]}"
            target_file = Consist.files.detect { |f| f[:id] == command[:local_file] }
            raise "\n\nNo declared file of ID `#{command[:local_file]}`" unless target_file

            contents = StringIO.new(target_file[:contents])
            upload_defined_file(executor, contents, command[:remote_path])
          else
            local_path = File.expand_path("../steps/#{@id}/#{command[:local_file]}", __dir__)
            upload(executor, local_path, command[:remote_path])
          end

        end
      end
    end

    private

    def exec(executor, command)
      executor.as @required_user do
        executor.send(:execute, command, interaction_handler: StreamOutputInteractionHandler.new)
      end
    end

    def upload(executor, local_path, remote_path)
      executor.as @required_user do
        executor.send(:upload!, local_path, remote_path, interaction_handler: StreamOutputInteractionHandler.new)
      end
    end

    def upload_defined_file(executor, contents, remote_path)
      executor.as @required_user do
        executor.upload! contents, remote_path
      end
    end

    def banner(message)
      return if message.empty?

      msg = "********* #{message} ********"
      puts "*" * msg.length
      puts msg
      puts "*" * msg.length
    end
  end
end
