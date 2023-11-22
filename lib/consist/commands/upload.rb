# frozen_string_literal: true

module Consist
  module Commands
    class Upload
      include Erbable

      def initialize(command)
        @command = command
      end

      def perform!(executor)
        if @command[:local_file].class == Symbol
          puts "---> Uploading defined file #{@command[:local_file]}"
          target_file = Consist.files.detect { |f| f[:id] == @command[:local_file] }
          raise "\n\nNo declared file of ID `#{@command[:local_file]}`" unless target_file

          contents = StringIO.new(erb_template(target_file[:contents]))
          upload_defined_file(executor, contents, @command[:remote_path])
        else
          local_path = File.expand_path("../steps/#{@id}/#{@command[:local_file]}", __dir__)
          upload(executor, local_path, @command[:remote_path])
        end
      end

      def upload(executor, local_path, remote_path)
        executor.send(:upload!, local_path, remote_path, interaction_handler: Consist::Commands::StreamLogger.new)
      end

      def upload_defined_file(executor, contents, remote_path)
        executor.upload! contents, remote_path, interaction_handler: Consist::Commands::StreamLogger.new
      end
    end
  end
end
