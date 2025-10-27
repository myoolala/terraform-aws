output "ipv4_cidrs" {
  value = concat([var.ipv4_cidr], var.secondary_ipv4_cidrs)
}

output "ipv6_assoc_id" {
  value = aws_vpc.main.ipv6_association_id
}

output "ipv6_cidr" {
  value = aws_vpc.main.ipv6_cidr_block
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "default_nacl_id" {
  value = aws_vpc.main.default_network_acl_id
}

output "default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
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

output "ingress_subnet_ids" {
  value = aws_subnet.ingress[*].id
}

output "compute_subnet_ids" {
  value = aws_subnet.compute[*].id
}