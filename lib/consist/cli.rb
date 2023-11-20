require "thor"

module Consist
  class CLI < Thor
    extend ThorExt::Start

    map %w[-v --version] => "version"

    desc "version", "Display consist version", hide: true
    def version
      say "consist/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
