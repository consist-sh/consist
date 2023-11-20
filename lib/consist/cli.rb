require "thor"
require "sshkit"
require "sshkit/dsl"

module Consist
  class CLI < Thor
    extend ThorExt::Start
    include SSHKit::DSL

    map %w[-v --version] => "version"

    desc "version", "Display consist version", hide: true
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
  end
end
