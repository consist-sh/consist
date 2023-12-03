# frozen_string_literal: true

module Consist
  class Resolver
    def initialize(pwd:)
      @pwd = pwd
    end

    def resolve_artifact(type:, id:)
      file_name = %i[recipe step].include?(type) ? "#{id}.rb" : id.to_s
      target_path = File.join(Consist.consist_dir, "#{type}s", file_name)
      artifact_path = File.expand_path(target_path, @pwd)
      File.read(artifact_path)
    end
  end
end
