require 'thor'
require 'json'
require 'erubis'
require 'fileutils'
require 'tty-tree'

module Clvpn
  BASE_PATH    = '/opt/ccui'                                              # Root directory
  CONFIG_FILE  = File.join(BASE_PATH, 'clvpn.json')                       # Config file
  VARS_TEMP    = File.expand_path("../../config/vars.json.erb", __FILE__) # Template for CA env vars
  CA_PATH      = File.join(BASE_PATH, 'certificate-authority')            # CA directory
  SERVERS_PATH = File.join(CA_PATH, 'servers')                            # Server certs directory
  CLIENTS_PATH = File.join(CA_PATH, 'clients')                            # Client certs directory

  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'clvpn')               # Require Clvpn base files
  %w[ca write version].each do |lib|
    require File.join(LIBRARY_PATH, lib)
  end

  class CLI < Thor
    # [version] Returns the current version of the Clvpn gem
    map '-v' => :version
    desc 'version', 'Display installed Clvpn version'
    def version
      puts Clvpn::VERSION
    end

    desc 'write', 'Create configuration files'
    subcommand 'write', Write

    desc 'ca', 'Manage certificate authority'
    subcommand 'ca', Ca
  end
end
