output "ipv4_cidrs" {
  value       = concat([var.ipv4_cidr], var.secondary_ipv4_cidrs)
  description = "IPV4 CIDR ranges in the VPC"
}

output "ipv6_assoc_id" {
  value       = aws_vpc.main.ipv6_association_id
  description = "Assotication ID for the IPV6 block"
}

output "ipv6_cidr" {
  value       = aws_vpc.main.ipv6_cidr_block
  description = "IPV6 cidr range for the VPC"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "IP of the VPC"
}

output "default_nacl_id" {
  value       = aws_vpc.main.default_network_acl_id
  description = "ID of the default NACL"
}

output "default_route_table_id" {
  value       = aws_vpc.main.default_route_table_id
  description = "ID of the default Route Table"
}

output "compute_subnet_route_mapping" {
  value       = local.compute_subnet_route_mapping
  description = "Compute subnet route mapping object for the Route Tables"
}

output "nat_subnet_map" {
  value       = local.nat_subnet_map
  description = "Mapping of subnets to NAT Gateways"
}

output "nat_az_map" {
  value       = local.nat_az_map
  description = "NAT Gateway to AZ mapping object"
}

output "ingress_subnet_ids" {
  value       = aws_subnet.ingress[*].id
  description = "IDs of the ingress subnets"
}

output "ingress_subnet_arns" {
  value       = aws_subnet.ingress[*].arn
  description = "ARNs of the ingress subnets"
}

output "compute_subnet_ids" {
  value       = aws_subnet.compute[*].id
  description = "IDs of the compute subnets"
}

output "compute_subnet_arns" {
  value       = aws_subnet.compute[*].arn
  description = "ARNs of the compute subnets"
}