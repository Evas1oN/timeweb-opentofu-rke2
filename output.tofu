output "ansible-inventory" {
  sensitive = true
  value = jsonencode(
    {
      proxies = {
        children = ["haproxy", "nginx"]
        vars = {
          ssl_privkey = var.ssl_privkey,
          ssl_fullchain = var.ssl_fullchain
        }
      },
      haproxy = {
        hosts = [
            twc_server.haproxy.hostname
        ]
      }
      k8s_cluster = {
        children = [
          "masters",
          "workers"
        ],
        vars = {
          ansible_user = "root",
          rke2_api_ip = twc_server.haproxy.main_ipv4
          rke2_token = var.rke2_token
          rke2_custom_registry_mirrors = [
            {
              name = "docker.io"
              endpoint = [
                "http://${twc_server.haproxy.networks[1].ips[0].ip}:5000"
              ]
            }
          ]
        }
      },
      masters = {
        hosts = twc_server.rke2-master-node[*].hostname
      },
      workers = {
        hosts = []
      }
      _meta = {
        hostvars = merge(
          { for node in twc_server.rke2-master-node : node.hostname => {
            ansible_host = node.networks[1].ips[0].ip
            private_ip_address = node.networks[1].ips[0].ip
            rke2_server_options = [
              "node-ip: ${node.networks[1].ips[0].ip}",
            ]
          }},
          {
            (twc_server.haproxy.hostname) = {
              ansible_host = twc_server.haproxy.main_ipv4
              private_ip_address = twc_server.haproxy.networks[1].ips[0].ip
            }
          }
        )
      }
    }
  )
}

output "ssh-config" {
  value = trimspace(<<-EOT
Host ${twc_server.haproxy.hostname}
  HostName ${twc_server.haproxy.main_ipv4}
  User root
%{ for node in twc_server.rke2-master-node }
Host ${node.networks[1].ips[0].ip}
  HostName ${node.networks[1].ips[0].ip}
  User root
  ProxyJump ${twc_server.haproxy.hostname}
%{ endfor }
EOT
  )
}