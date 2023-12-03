require "fileutils"

require "thor"
require "sshkit"
require "sshkit/dsl"

require "consist/utils"
require "consist/resolver"
require "consist/recipe"
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
    include Thor::Actions
    include SSHKit::DSL

    map %w[-v --version] => "version"

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "version", "Display consist version"
    def version
      say "consist/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    desc "ping", "Attempt to connect to a server and execute an idempotent statement."
    def ping(user, server)
      puts "---> Attempting to connect to #{server} as #{user}"
      on("#{user}@#{server}") do
        as user do
          execute "true"
        end
      end
    end

    option :step, type: :string
    option :consistfile, type: :string
    option :consistdir, type: :string
    desc "up", "Run a Consistfile against a server"
    def up(server_ip)
      specified_step = options[:step]
      consistfile = options[:consistfile]
      consist_dir = options[:consistdir]
      Consist::Consistfile.new(server_ip, consist_dir:, consistfile:, specified_step:)
    end

    desc "init", "Initialize a project with Consist, optionally specifying a GH path to a Consistfile"
    def init(gh_path = nil)
      if gh_path
        full_url = "https://github.com/#{gh_path}"
        Consist::Utils.clone_repo_contents(full_url, Dir.pwd)
      else
        puts "Creating new Consistfile..."
        directory "templates/.consist", File.join(Dir.pwd, ".consist")
        template "templates/Consistfile.tt", File.join(Dir.pwd, "Consistfile")
        puts "...done"
      end
    end
  end
end
