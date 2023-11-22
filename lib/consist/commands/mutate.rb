# frozen_string_literal: true

module Consist
  module Commands
    class Mutate
      def initialize(command)
        @command = command
      end

      def perform!(executor)
        @command[:commands].each do
          executor.execute(erb_template(_1), interaction_handler: Consist::Commands::StreamLogger.new)
        end
      end
    end
  end
end
