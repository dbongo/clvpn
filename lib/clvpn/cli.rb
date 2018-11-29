module Clvpn
  class CLI < Thor
    # [Version]
    # Returns the current version of the Clvpn gem
    map "-v" => :version
    desc "version", "Display installed Clvpn version"
    def version
      puts "Clvpn #{Clvpn::VERSION}"
    end
  end
end
