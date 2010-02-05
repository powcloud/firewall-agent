require "active_support/core_ext/integer"

class Policy
  include SlicehostSupport

  attr_reader :name, :logger

  def initialize(dsl_file, logger)
    @stack = []
    @top = []
    @stack.push(@top)
    @dirty = false
    @logger = logger

    instance_eval File.open(dsl_file).read, dsl_file
  end

  def rules
    @top
  end

  def dirty?
    @dirty
  end

  def clean
    @dirty = false
  end

  def config
    yield
  end

  def policy(name = :unnamed)
    @name = name
    yield
  end

  def allow_ip(ip)
    add_rule IptablesGenerator.allow_ip ip
  end

  def allow_ips(*hosts)
    hosts = hosts.first if hosts.length == 1 && hosts.first.instance_of?(Array)
    add_rule IptablesGenerator.allow_ips hosts
  end

  def allow_listen(*ports)
    ports = ports.first if ports.length == 1 && ports.first.instance_of?(Array)
    add_rule IptablesGenerator.allow_listen(ports)
  end

  def allow_slicehost_slices(key)
    add_rule IptablesGenerator.allow_slicehost_slices(key)
  end

  def allow_established
    add_rule IptablesGenerator.allow_established
  end

  def allow_ping
    add_rule IptablesGenerator.allow_ping
  end

  def allow_ssh
    add_rule IptablesGenerator.allow_ssh
  end

  def deny_all
    add_rule IptablesGenerator.deny_all
  end

  def add_rule(rule)
    @dirty = true
    @stack.last << rule
  end

  def update(options = {})
    index = @stack.last.length

    @stack.push([])
    yield
    rules = @stack.pop
    @stack.last[index] = rules

    period = options[:each].to_i
    if period > 0
      EM.add_periodic_timer period do
        rules.clear
        @stack.push(rules)
        yield
        @stack.pop
      end
    end
  end
end