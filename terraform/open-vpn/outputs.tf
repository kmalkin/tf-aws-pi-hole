output "open_vpn_public_ip" {
  description = "OpenVPN Public IP created"
  value       = aws_eip.open_vpn_elastic_ip.public_ip
}

output "openvpn" {
  description = "DNS Entry"
  value       = join("", aws_route53_record.openvpn.*.fqdn)
}