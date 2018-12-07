module Clvpn
  class Write < Thor

    desc 'vars', 'Configure the CA env variables'
    method_option :dir,      type: :string,  required: true, default: Clvpn::CA_PATH,           desc: 'CA Directory'
    method_option :size,     type: :numeric, required: true, default: 2048, enum: [2048, 4096], desc: 'CA Size'
    method_option :country,  type: :string,  required: true, default: 'US',                     desc: 'Country'
    method_option :city,     type: :string,  required: true, default: 'TX',                     desc: 'State'
    method_option :province, type: :string,  required: true, default: 'Austin',                 desc: 'City'
    method_option :org,      type: :string,  required: true, default: 'bobloblawslawblog.com',  desc: 'Organization'
    method_option :email,    type: :string,  required: true, default: 'bobloblaw@lawblog.com',  desc: 'Email'
    method_option :ou,       type: :string,  required: true, default: 'Law',                    desc: 'Organizational Unit'
    method_option :name,     type: :string,  required: true, default: 'BobLobLaw-CA',           desc: 'CA Name'

    def vars
      eruby = Erubis::Eruby.new(File.read(Clvpn::VARS_TEMP))
      out = eruby.evaluate(options)

      FileUtils.mkdir_p(File.dirname(Clvpn::CONFIG_FILE))
      File.open(Clvpn::CONFIG_FILE, 'w+'){|f| f.puts(out)}

      unless File.exist?(Clvpn::CONFIG_FILE)
        error 'Error writing vars'
      end
      say File.read Clvpn::CONFIG_FILE
    end


    desc 'ca', 'Setup a root certificate authority'
    method_option :dir_owner, type: :string,                 desc: 'Directory owner'
    method_option :dir_group, type: :string,                 desc: 'Directory group'
    method_option :umask,     type: :numeric, default: 0377, desc: 'Umask'

    def ca
      return if !File.exist?(Clvpn::CONFIG_FILE) && Dir.exist?(Clvpn::CA_PATH)
      mk_ca_dirs(options)
      mk_ca_files(options)

      tree = TTY::Tree.new(Clvpn::CA_PATH, show_hidden: true)

      say tree.render
    end

    private

    def mk_ca_dirs(options)
      [Clvpn::CA_PATH, Clvpn::SERVERS_PATH, Clvpn::CLIENTS_PATH].each do |dir|
        FileUtils.mkdir_p dir

        if options[:dir_owner] && options[:dir_group]
          FileUtils.chown_R options[:dir_owner], options[:dir_group], dir
        end
      end
    end

    def mk_ca_files(options)
      FileUtils.cd(Clvpn::CA_PATH) do
        File.new('index.txt', 'w', 0600).close
        File.open('serial', 'w', 0600){|f| f.puts '01'}

        export_ca_vars = "export #{cli_vars}; "
        status = system("#{export_ca_vars} /usr/share/easy-rsa/pkitool --initca", umask: options[:umask])
        unless status
          FileUtils.rm_rf(Clvpn::CA_PATH)
          exit(2)
        end

        system("rm -f $RT")
        opts = {'KEY_CN' => "", 'KEY_OU' => "", 'KEY_NAME' => "", 'KEY_ALTNAMES' => ""}

        export_clr_vars = "export #{cli_vars(opts)}; "
        status = system("#{export_clr_vars} $OPENSSL ca -gencrl -out crl.pem -config $KEY_CONFIG")
        unless status
          FileUtils.rm_rf(Clvpn::CA_PATH)
          exit(2)
        end

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

    def ca_vars
      vars ||= JSON.parse(File.read(Clvpn::CONFIG_FILE))['vars'] rescue nil
    end

    def cli_vars(append=nil)
      return if ca_vars.nil?

      result = ""
      ca_vars.each do |k, v|
        ku = k.upcase
        result += "#{ku}=\"#{v}\" "
      end

      if append.is_a?(Hash)
        append.each do |k, v|
          ku = k.upcase
          result += "#{ku}=\"#{v}\" "
        end
      end
      result
    end
  end
end