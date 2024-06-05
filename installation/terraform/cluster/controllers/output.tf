output "ip_addresses" {
  value = [for m in aws_network_interface.controller : tolist(m.private_ips)[0]]
}