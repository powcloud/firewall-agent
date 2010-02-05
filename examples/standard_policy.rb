policy :standard_policy do
  deny_all             # deny all connections from all hosts
  allow_listen 'http'  # let HTTP connections in
  allow_established    # allow all established TCP connections
  allow_ping           # let any host ping this server
  allow_ssh            # allow SSH connections
end
