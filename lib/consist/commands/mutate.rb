# frozen_string_literal: true

module Consist
  module Commands
    class Mutate
      include Erbable

      def initialize(command)
        @command = command
      end

      def perform!(executor)
        target_file = @command[:target_file]
        target_string = erb_template(@command[:target_string])
        match = erb_template(@command[:match])

        case @command[:mode]
        when :replace
          cmd = "sed -i -E \"s/#{match}/#{target_string}/\" #{target_file} "
        end

        executor.execute(cmd, interaction_handler: Consist::Commands::StreamLogger.new)
      end
    end
  end
end
