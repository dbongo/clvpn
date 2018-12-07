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
  end
end