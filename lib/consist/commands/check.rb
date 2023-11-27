# frozen_string_literal: true

module Consist
  module Commands
    class Check
      def initialize(command)
        @command = command
      end

      def perform!(executor)
        status = @command[:status]

        flag, val = if @command.has_key?(:path) && !@command[:path].nil?
          ["d", @command[:path]]
        else
          ["f", @command[:file]]
        end

        exists = executor.test("[ -#{flag} #{val} ]")

        if status == :exist && !exists
          @command[:block].call
        elsif status == :nonexistant && !exists
          @command[:block].call
        else
          tense = if status == :exist
            "should"
          elsif status == :nonexistant
            "shoudlnt"
          end
          puts "Checking path `#{status}` - `#{val}` - #{exists ? "exists" : "doesn't exist"} and #{tense} - skipping"
        end
      end
    end
  end
end
