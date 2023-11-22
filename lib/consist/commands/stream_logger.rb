# frozen_string_literal: true

module Consist
  module Commands
    class StreamLogger
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
  end
end
