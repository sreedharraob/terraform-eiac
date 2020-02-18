#cloud-config
package_upgrade: true
packages:
  - squid
write_files:
  - owner: root:root
    path: /etc/squid/squid.conf.new
    content: |
      acl localnet src ${network_octets}.0.0/16
      acl whitelist dstdomain /etc/squid/whitelist.txt

      acl SSL_ports port 443

      acl Safe_ports port 80  # http
      acl Safe_ports port 21  # ftp
      acl Safe_ports port 443 # https
      acl Safe_ports port 70  # gopher
      acl Safe_ports port 210 # wais
      acl Safe_ports port 1025-65535  # unregistered ports
      acl Safe_ports port 280 # http-mgmt
      acl Safe_ports port 488 # gss-http
      acl Safe_ports port 591 # filemaker
      acl Safe_ports port 777 # multiling http

      acl CONNECT method CONNECT

      http_access deny !Safe_ports
      http_access deny CONNECT !SSL_ports

      http_access allow localhost manager
      http_access deny manager

      http_access allow whitelist
      http_access allow localnet
      http_access allow localhost
      http_access deny all
      
      http_port 3128
      
      coredump_dir /var/spool/squid

      refresh_pattern ^ftp: 1440  20% 10080
      refresh_pattern ^gopher:  1440  0%  1440
      refresh_pattern -i (/cgi-bin/|\?) 0 0%  0
      refresh_pattern (Release|Packages(.gz)*)$ 0 20% 2880
      refresh_pattern . 0 20% 4320

      forwarded_for transparent
  - owner: root:root
    path: /etc/squid/whitelist.txt
    content: |
      ${private_zone}
      .${private_zone}
runcmd:
  - sudo mv /etc/squid/squid.conf /etc/squid/squid.conf.bak 
  - sudo mv /etc/squid/squid.conf.new /etc/squid/squid.conf 
  - systemctl enable squid
  - systemctl restart squid



