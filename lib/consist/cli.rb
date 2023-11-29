require "thor"
require "sshkit"
require "sshkit/dsl"

require "consist/recipe"
require "consist/recipes"
require "consist/step"
require "consist/consistfile"
require "consist/commands/includes/stream_logger"
require "consist/commands/includes/erbable"
require "consist/commands/exec"
require "consist/commands/upload"
require "consist/commands/mutate"
require "consist/commands/check"

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

    option :step, type: :string
    option :consistfile, type: :string
    desc "up", "Run a Consistfile against a server"
    def up(server_ip)
      specified_step = options[:step]
      consistfile = options[:consistfile]
      Consist::Consistfile.new(server_ip, consistfile:, specified_step:)
    end
  end
end
