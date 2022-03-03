output "pool" {
  description = "IPAM sub pool info."
  value       = aws_vpc_ipam_pool.sub
}

output "cidr" {
  description = "IPAM sub pool provisioned CIDR info."
  value       = aws_vpc_ipam_pool_cidr.sub
}
