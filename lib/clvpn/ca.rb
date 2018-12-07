module Clvpn
  class CA < Thor
    desc 'status', 'Output info about certificate authority'
    def status
      out = { ca: nil }
      crt = Dir.glob(File.join(Clvpn::CA_PATH, '*.crt')).first
      if File.exist?(crt)
        stat = File.stat(crt)
        out.merge!(
          ca: {
            name: File.basename(crt),
            path: crt,
            perm: stat.mode & 07777,
            uid: stat.uid,
            gid: stat.gid
          }
        )
      end
      puts JSON.pretty_generate(out)
    rescue
      puts JSON.generate(out)
    end
  end
end
