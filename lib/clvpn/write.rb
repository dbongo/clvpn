module Clvpn
  class Write < Thor
    desc 'vars', 'Configure the CA env variables'

    method_option :dir,      type: :string,  default: Clvpn::CA_PATH,           required: true, desc: 'CA Directory'
    method_option :size,     type: :numeric, default: 2048, enum: [2048, 4096], required: true, desc: 'CA Size'
    method_option :country,  type: :string,  default: 'US',                     required: true, desc: 'Country'
    method_option :city,     type: :string,  default: 'TX',                     required: true, desc: 'State'
    method_option :province, type: :string,  default: 'Austin',                 required: true, desc: 'City'
    method_option :org,      type: :string,  default: 'bobloblawslawblog.com',  required: true, desc: 'Organization'
    method_option :email,    type: :string,  default: 'bobloblaw@lawblog.com',  required: true, desc: 'Email'
    method_option :ou,       type: :string,  default: 'Law',                    required: true, desc: 'Organizational Unit'
    method_option :name,     type: :string,  default: 'BobLobLaw-CA',           required: true, desc: 'CA Name'

    def vars
      eruby = Erubis::Eruby.new(File.read(Clvpn::VARS_TEMP))
      out = eruby.evaluate(options)

      FileUtils.mkdir_p(File.dirname(Clvpn::CONFIG_FILE))
      File.open(Clvpn::CONFIG_FILE, 'w+'){|f| f.puts(out)}

      if File.exist?(Clvpn::CONFIG_FILE)
        puts File.read(Clvpn::CONFIG_FILE)
      else
        puts 'Error writing vars'
      end
    end


    desc 'ca', 'Setup a root certificate authority'

    method_option :dir_owner, type: :string,                 desc: 'Directory owner'
    method_option :dir_group, type: :string,                 desc: 'Directory group'
    method_option :umask,     type: :numeric, default: 0377, desc: 'Umask'

    def ca
      if Dir.exist?(Clvpn::CA_PATH)
        puts 'There is already a root CA on this systm'
        exit(1)
      elsif !File.exist?(Clvpn::CONFIG_FILE)
        puts 'Must configure the CA env variables first'
        exit(1)
      end

      [Clvpn::CA_PATH, Clvpn::SERVERS_PATH, Clvpn::CLIENTS_PATH].each do |dir|
        FileUtils.mkdir_p dir
        if options[:dir_owner] && options[:dir_group]
          FileUtils.chown_R options[:dir_owner], options[:dir_group], dir
        end
      end

      vars = JSON.parse(File.read(Clvpn::CONFIG_FILE))['vars']
      cli_vars = ""
      vars.each do |k, v|
        ku = k.upcase
        cli_vars += "#{ku}=\"#{v}\" "
      end
      export_ca_vars = "export #{cli_vars}; "

      FileUtils.cd(Clvpn::CA_PATH) do
        File.new('index.txt', 'w', 0600).close
        File.open('serial', 'w', 0600){|f| f.puts '01'}

        status = system("#{export_ca_vars} /usr/share/easy-rsa/pkitool --initca", umask: options[:umask])
        unless status
          FileUtils.rm_rf(Clvpn::CA_PATH)
          exit(2)
        end

        system("rm -f $RT")
        {'KEY_CN' => "", 'KEY_OU' => "", 'KEY_NAME' => "", 'KEY_ALTNAMES' => ""}.each do |k, v|
          cli_vars += "#{k}=\"#{v}\" "
        end
        export_clr_vars = "export #{cli_vars}; "
        system("#{export_clr_vars} $OPENSSL ca -gencrl -out crl.pem -config $KEY_CONFIG")
        FileUtils.chmod(0640, 'crl.pem')
        FileUtils.chown('root', 'nogroup', 'crl.pem')

        status = system("#{export_ca_vars} $OPENSSL dhparam -dsaparam -out ${KEY_DIR}/dh${KEY_SIZE}.pem ${KEY_SIZE}", umask: options[:umask])
        unless status
          FileUtils.rm_rf(Clvpn::CA_PATH)
          exit(2)
        end

        FileUtils.chmod(0400, 'ca.key')
      end
    end
  end
end