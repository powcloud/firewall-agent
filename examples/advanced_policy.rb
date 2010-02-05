require 'resolve'
policy :advanced_policy do
  deny_all
  allow_listen 'http', 'https'

  update :each => 5.minutes do
    allow_ips slicehost_get_ips('https://8fff02f2853@api.slicehost.com/')
  end

  # 3 different schedules for different types of policy elememnts
  # this block will enable you to always access all services on
  # this host - even when your IP changes, via a Dynamic DNS service
  update :each => 10.minutes do
    allow_ips Resolv.getaddress('your-desktop.dyndns.org')
    allow_ips Resolv.getaddress('your-laptop.dyndns.org')
  end

  # disable printing using CUPS/IPP outside of business hours
  update :each => 1.minutes do
    now = Time.now
    allow_listen 631 unless now.hour < 8 || now.hour > 18
  end

  allow_established
  allow_ping
  allow_ssh
end
