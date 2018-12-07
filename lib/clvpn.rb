require 'thor'
require 'json'

module Clvpn
  # Root directory
  BASE_PATH    = '/opt/ccui'

  # Config file
  CONFIG       = File.join(BASE_PATH, 'clvpn.json')

  # CA directory
  CA_PATH      = File.join(BASE_PATH, 'certificate-authority')

  # Server certs directory
  SERVERS_PATH = File.join(CA_PATH, 'servers')

  # Client certs directory
  CLIENTS_PATH = File.join(CA_PATH, 'clients')

  # DB directory
  # DB_PATH    = '/var/db/clvpn'

  # DB file
  # DATABASE   = File.join(DB_PATH, 'clvpn.sqlite3')

  # Require Clvpn base files
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'clvpn')
  %w[
    ca
    write
    cli
    version
  ].each { |lib| require File.join(LIBRARY_PATH, lib) }
end
