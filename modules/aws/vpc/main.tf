locals {
  other_subnets = flatten([for name, subnet_group in var.other_subnets : [
    for i, subnet in subnet_group :
      merge(subnet, {
        name = "${name}-${i + 1}"
      })
  ]])

  # Map of the indexes for the ingress subnets that contain a nat gateway
  nat_subnet_map = [for i, v in var.ingress_subnets : i if v.nat == true]
  # Map of az to the ingress subnet index
  nat_az_map = { for i, v in var.ingress_subnets :
    v.az => i if v.nat
  }
  # Mapping of compute subnets to their azs then mapped to the matching ingress subnet id joined by az if possible
  # If no match is found, default is random pick
  compute_subnet_route_mapping = [ for i, v in var.compute_subnets: 
    index(local.nat_subnet_map, lookup(local.nat_az_map, v.az, local.nat_subnet_map[i % length(local.nat_subnet_map)]))
  ]
  other_subnet_route_mapping = [ for i, v in local.other_subnets: 
    index(local.nat_subnet_map, lookup(local.nat_az_map, v.az, local.nat_subnet_map[i % length(local.nat_subnet_map)]))
  ]
  create_internal_rt = var.public && length(var.compute_subnets) + length(local.other_subnets) > 0
}

resource "aws_vpc" "main" {
  cidr_block       = var.ipv4_cidr
  # ipv6_cidr_block  = var.ipv6_cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  

  tags = {
    Name = var.name
  }
}

# @TODO: filter these with locals to make a single input
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count = length(var.secondary_ipv4_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.secondary_ipv4_cidrs[count.index]
}

# @TODO figure this out
# resource "aws_vpc_ipv6_cidr_block_association" "secondary_cidr" {
#   count = length(var.secondary_ipv6_cidrs)

#   vpc_id     = aws_vpc.main.id
#   # ipv6_ipam_pool_id = 
#   ipv6_cidr_block = var.secondary_ipv6_cidrs[count.index]
# }

resource "aws_subnet" "ingress" {
  count = length(var.ingress_subnets)

  vpc_id = aws_vpc.main.id
  cidr_block = var.ingress_subnets[count.index].ipv4_cidr
  ipv6_cidr_block = var.ingress_subnets[count.index].ipv6_cidr
  ipv6_native = var.ingress_subnets[count.index].ipv6_native
  availability_zone = var.ingress_subnets[count.index].az
  map_public_ip_on_launch = var.public
  # enable_resource_name_dns_aaaa_record_on_launch = var.public && var.ingress_subnets[count.index].ipv6_cidr != null
  assign_ipv6_address_on_creation = var.public && var.ingress_subnets[count.index].ipv6_cidr != null

  tags = {
    Name = "${var.name}-Ingress-${count.index + 1}"
  }
}

resource "aws_subnet" "compute" {
  count = length(var.compute_subnets)

  vpc_id = aws_vpc.main.id
  cidr_block = var.compute_subnets[count.index].ipv4_cidr
  ipv6_cidr_block = var.compute_subnets[count.index].ipv6_cidr
  ipv6_native = var.compute_subnets[count.index].ipv6_native
  availability_zone = var.compute_subnets[count.index].az

  tags = {
    Name = "${var.name}-Compute-${count.index + 1}"
  }
}

resource "aws_subnet" "other_subnets" {
  count = length(local.other_subnets)

  vpc_id = aws_vpc.main.id
  cidr_block = local.other_subnets[count.index].ipv4_cidr
  ipv6_cidr_block = local.other_subnets[count.index].ipv6_cidr
  ipv6_native = local.other_subnets[count.index].ipv6_native
  availability_zone = local.other_subnets[count.index].az

  tags = {
    Name = local.other_subnets[count.index].name
  }
}

resource "aws_default_route_table" "primary" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.name}-default"
  }
}

resource "aws_internet_gateway" "gw" {
  count = var.public ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_route" "public_routes_ipv4" {
  count = var.public && var.ipv4_cidr != null ? 1 : 0

  route_table_id            = aws_default_route_table.primary.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw[0].id
}

resource "aws_route" "public_routes_ipv6" {
  count = var.public && var.ipv6_cidr != null ? 1 : 0

  route_table_id            = aws_default_route_table.primary.id
  destination_ipv6_cidr_block    = "::/0"
  gateway_id = aws_internet_gateway.gw[0].id
}

resource "aws_route_table" "internal" {
  count = local.create_internal_rt ? length(local.nat_subnet_map) : 0
  
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-internal-${var.ingress_subnets[count.index].az}"
  }
}

resource "aws_eip" "nat" {
  count = var.public ? length(local.nat_subnet_map) : 0

  depends_on = [
    aws_internet_gateway.gw,
    aws_subnet.ingress
  ]
}

resource "aws_nat_gateway" "private_internet_access" {
  count = var.public ? length(local.nat_subnet_map) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.ingress[local.nat_subnet_map[count.index]].id

  tags = {
    Name = "${var.name}-${var.ingress_subnets[local.nat_subnet_map[count.index]].az}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.gw,
    aws_subnet.ingress,
    aws_eip.nat
  ]
}

resource "aws_route_table_association" "ingress" {
  count = length(var.ingress_subnets)

  subnet_id      = aws_subnet.ingress[count.index].id
  route_table_id = aws_default_route_table.primary.id
}

resource "aws_route_table_association" "compute" {
  count = length(var.compute_subnets)

  # @TODO this does not normalize to az matches to minimize latency and cost
  subnet_id      = aws_subnet.compute[count.index].id
  route_table_id = local.create_internal_rt ? aws_route_table.internal[local.compute_subnet_route_mapping[count.index]].id : aws_default_route_table.primary.id
}

resource "aws_route_table_association" "other" {
  count = length(local.other_subnets)

  # @TODO this does not normalize to az matches to minimize latency and cost
  subnet_id      = aws_subnet.other_subnets[count.index].id
  route_table_id = local.create_internal_rt ? aws_route_table.internal[0].id : aws_default_route_table.primary.id
}

resource "aws_route" "nat_gateways_ipv4" {
  count = local.create_internal_rt && var.ipv4_cidr != null ? length(local.nat_subnet_map) : 0

  route_table_id            = aws_route_table.internal[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.private_internet_access[count.index].id
}

resource "aws_route" "nat_gateways_ipv6" {
  count = local.create_internal_rt && var.ipv6_cidr != null ? length(local.nat_subnet_map) : 0

  route_table_id            = aws_route_table.internal[count.index].id
  destination_ipv6_cidr_block    = "::/0"
  nat_gateway_id = aws_nat_gateway.private_internet_access[count.index].id
}