require "fileutils"
require "tmpdir"

module Consist
  module Utils
    extend self

    def clone_repo_contents(source_repo, target_dir)
      temp_dir = Dir.mktmpdir

      puts "Using #{source_repo} as template to initialize Consistfile..."
      system("git clone --depth=1 #{source_repo} #{temp_dir} >/dev/null 2>&1")

      Dir.foreach(temp_dir) do |item|
        next if [".", "..", ".git"].include?(item)

        source_path = File.join(temp_dir, item)
        target_path = File.join(target_dir, item)
        FileUtils.cp_r(source_path, target_path)
      end

      FileUtils.remove_entry_secure(temp_dir)

      puts "...done"
    end
  end
end
