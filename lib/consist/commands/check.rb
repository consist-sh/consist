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

        puts "--------> #{flag} #{val} #{exists}"
        if status == :exist && !exists
          @command[:block].call
        elsif status == :nonexistant && !exists
          @command[:block].call
        else
          puts "Checking path `#{status}` - `#{val}` - #{exists ? "exists" : "doesn't exist"} and #{if status == :exist
                                                                                                      "should"
                                                                                                    elsif status == :nonexistant
                                                                                                      "shoudlnt"
                                                                                                    end} skipping"
        end
      end
    end
  end
end
