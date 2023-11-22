# frozen_string_literal: true

require "erb"

module Consist
  module Commands
    module Erbable
      def self.included(klass)
        klass.extend ClassMethods
      end

      def erb_template(contents)
        b = binding
        Consist.config.keys.each do |key|
          b.local_variable_set(key, Consist.config[key])
        end
        ERB.new(contents).result(b)
      end

      module ClassMethods
      end
    end
  end
end
