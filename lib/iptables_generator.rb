module IptablesGenerator
  class << self

    def deny_all
# Default to dropping unmatched input, Default to dropping unmatched forward requests, Allow all outgoing requests, Allow everything on loopback
<<EOS_DENY_ALL
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
EOS_DENY_ALL
    end

    def allow_established
      "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n"
    end

    def allow_ping
      "-A INPUT -p icmp --icmp-type any -j ACCEPT\n"
    end

    def allow_ssh
      "-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT\n"
    end

    def allow_ip(ip)
      "-A INPUT -s #{ip} -j ACCEPT\n"
    end

    def allow_ips(ips)
      ips.map{ |ip| allow_ip(ip) }.join ''
    end

    # Rule to open a given port(s)
    def allow_listen(ports, prot = 'tcp', nic = 'all')
      if ports.empty?
        return ''
      end

      # -A INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
      result = "-A INPUT"

      # Did we want a specific nics?
      #TODO: Convert this to an options hash
      if (nic != 'all' )
        result << " -i #{nic}"
      end

      result << " -p #{prot} -m multiport --dport #{ports.join(",")} -j ACCEPT\n"
      result
    end
  end
end