require 'log4r'
require 'log4r/outputter/syslogoutputter'
require 'eventmachine'

this_dir = File.dirname(__FILE__)
require "#{this_dir}/iptables_generator"
require "#{this_dir}/slicehost_support"
require "#{this_dir}/policy"

class FirewallAgent
  attr_reader :logger

  IPTABLES_FILE = "/etc/sysconfig/iptables"
  DEFAULT_POLICY_FILE = '/etc/firewall-agent/policy.rb'

  def initialize
    @logger = Log4r::Logger.new File.basename(__FILE__)
  end

  def stop
    logger.warn "Stopping..."
    EM.stop
  end

  def start(policy_filename)
    unless File.exists? policy_filename
      logger.error "Policy file (#{policy_filename}) not found, exiting..."
      exit 1 
    end

    EM.run do
      Signal.trap('INT') { stop }
      Signal.trap('TERM'){ stop }

      policy = Policy.new policy_filename, logger

      logger.warn "Starting agent"
      logger.warn "Applying dynamic firewall policy #{policy.name.to_s} from #{policy_filename}"

      apply_policy(policy)

      EM.add_periodic_timer 5 do
        apply_policy(policy) if policy.dirty?
      end
    end
  end

  def self.start(policy_filename = DEFAULT_POLICY_FILE)
    agent = self.new

    formatter = Log4r::PatternFormatter.new(:pattern => "[%5l] %d %C - %m")
    Log4r::StdoutOutputter.new('console', :formatter => formatter)
    Log4r::SyslogOutputter.new('syslog', :ident => File.basename(__FILE__))
    agent.logger.outputters = ['syslog', 'console']

    agent.start(policy_filename)
  end

  private

  def apply_policy(policy)
    logger.debug "apply_policy"

    iptables = generate_iptables(policy)
    policy.clean

    # Read in old file
    if File.exists?(IPTABLES_FILE)
      begin
        old_iptables = File.read(IPTABLES_FILE)
      rescue Exception => ex
        log_exception ex
        exit 1
      end
    else
      old_iptables = ''
    end

    # Restart service if changed
    if old_iptables != iptables
      logger.warn "Updating and restarting IPTables..."
      open(IPTABLES_FILE , 'w') { |f|  f.puts iptables  }
      system 'service iptables restart > /dev/null'
      logger.warn "Policy enabled"
    else
      logger.debug "apply_policy - no changes"
    end
  end

  def generate_iptables(policy)
    policy.rules.flatten.join("\n") + "\nCOMMIT\n"
  end

  def log_exception(ex)
    logger.error ex.to_s + (ex.backtrace.length > 0 ? ' ' + ex.backtrace.first : '')
  end
end

