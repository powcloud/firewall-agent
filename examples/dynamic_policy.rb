policy :dynamic_policy do
  deny_all
  allow_listen 'http', 'https'  # list multiple services or ports as needed

  # Firewall-agent will whitelist all slices in your account, enabling a Virtual Private Network for your slices
  update :each => 5.minutes do
    allow_ips slicehost_get_ips('https://8fff02f2853....@api.slicehost.com/')
  end

  allow_established
  allow_ping
  allow_ssh
end
