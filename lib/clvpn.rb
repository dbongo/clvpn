require "thor"

module Clvpn
  # Clvpn's internal paths
  LIBRARY_PATH = File.join(File.dirname(__FILE__), "clvpn")

  # Require Clvpn base files
  %w[cli version].each { |lib| require File.join(LIBRARY_PATH, lib) }
end
