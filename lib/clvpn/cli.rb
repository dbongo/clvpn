module Clvpn
  class CLI < Thor
    # [version]
    # Returns the current version of the Clvpn gem
    map '-v' => :version
    desc 'version', 'Display installed Clvpn version'
    def version
      puts "Clvpn #{Clvpn::VERSION}"
    end

    desc 'write [SUBCOMMAND]', 'Create configuration files'
    subcommand 'write', Write

    desc 'ca [SUBCOMMAND]', 'Manage certificate authority'
    subcommand 'ca', CA
  end
end
