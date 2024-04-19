output "ipv4_cidrs" {
  value = concat([var.ipv4_cidr], var.secondary_ipv4_cidrs)
}

output "ipv6_cidrs" {
  value = concat([var.ipv6_cidr], var.secondary_ipv6_cidrs)
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "compute_subnet_route_mapping" {
  value = local.compute_subnet_route_mapping
}

output "nat_subnet_map" {
  value = local.nat_subnet_map
}

output "nat_az_map" {
  value = local.nat_az_map
}