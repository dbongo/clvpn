module Clvpn
  class Write < Thor
    # [config]
    # Write the default config file
    desc 'config', 'Create the default config file'

    long_desc <<-EOS.gsub(/^ +/, "")
      Absolute path to the config file
      Defaults to: #{Clvpn::CONFIG}
    EOS

    method_option :path,
      type: :string,
      desc: 'Path to the config file'

    def config
      file = options[:path] ? File.expand_path(options[:path]) : Clvpn::CONFIG
      FileUtils.mkdir_p(File.dirname(file))
      out = JSON.pretty_generate({
        props: {
          easy_rsa: '/usr/share/easy-rsa',
          pkcs11tool: 'pkcs11-tool',
          grep: 'grep',
          pkcs11_module_path: 'dummy',
          pkcs11_pin: 'dummy',
          ca_expire: 3650,
          key_config: '/usr/share/easy-rsa/openssl-1.0.0.cnf',
          key_dir: Clvpn::CA_PATH,
          key_size: 2048,
          key_expire: 3650,
          key_country: 'US',
          key_province: 'TX',
          key_city: 'Austin',
          key_org: 'bobloblawslawblog.com',
          key_email: 'bobloblaw@lawblog.com',
          key_ou: 'Law',
          key_name: 'BobLobLaw-CA',
          openvpn: '/usr/sbin/openvpn',
          openssl: '/usr/bin/openssl',
          bt_hw_tls: '1',
          bt_cryptodev: '1'
        }
      })
      File.open(file, "w+"){|f| f.puts(out)}
      if File.exist?(file)
        puts out
      else
        puts 'Error writing config'
      end
    end
  end
end
