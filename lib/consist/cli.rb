require "thor"
require "sshkit"
require "sshkit/dsl"

require "consist/recipe"
require "consist/recipes"
require "consist/step"
require "consist/consistfile"
require "consist/commands/stream_logger"
require "consist/commands/erbable"
require "consist/commands/exec"
require "consist/commands/upload"

module Consist
  class CLI < Thor
    extend ThorExt::Start

    map %w[-v --version] => "version"

    desc "version", "Display consist version"
    def version
      say "consist/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    desc "lightup", "Attempt to connect to a server and execute an idempotent statement."
    def lightup(user, server)
      puts "---> Attempting to connect to #{server} as #{user}"
      on("#{user}@#{server}") do
        as user do
          execute "true"
        end
      end
    end

    desc "scaffold", "Apply a given recipe to (a) server(s)"
    def scaffold(_recipe, server_ip)
      Consist::Recipes.new(server_ip)
    end

    desc "up", "Run a Consistfile against a server"
    def up(server_ip)
      Consist::Consistfile.new(server_ip)
    end
  end
end
