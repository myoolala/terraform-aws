locals {
  other_subnets = flatten([for name, subnet_group in var.other_subnets : [
    for i, subnet in subnet_group :
      merge(subnet, {
        name = "${name}-${i + 1}"
      })
  ]])
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = var.instance_tenancy
  enable_dns_support = true
  enable_dns_hostnames = true

  # @TODO secondary cidr's
  secondary_cidrs = var.secondary_cidrs

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "ingress" {
  count = length(var.ingress_subnets)

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.ingress_subnets[count.index].cidr
  ipv6_cidr_block = var.ingress_subnets[count.index].ipv6_cidr
  ipv6_native = var.ingress_subnets[count.index].ipv6_native
  availability_zone = var.ingress_subnets[count.index].az
  map_public_ip_on_launch = var.public
  enable_resource_name_dns_aaaa_record_on_launch = var.public

  tags = {
    Name = "${var.vpc_name}-Ingress-${count.index + 1}"
  }
}

resource "aws_subnet" "compute" {
  count = length(var.compute_subents)

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.compute_subents[count.index].cidr
  ipv6_cidr_block = var.compute_subents[count.index].ipv6_cidr
  ipv6_native = var.compute_subents[count.index].ipv6_native
  availability_zone = var.compute_subents[count.index].az

  tags = {
    Name = "${var.vpc_name}-Compute-${count.index + 1}"
  }
}

resource "aws_subnet" "other_subnets" {
  count = length(local.other_subnets)

  vpc_id = aws_vpc.vpc.id
  cidr_block = local.other_subnets[count.index].cidr
  ipv6_cidr_block = local.other_subnets[count.index].ipv6_cidr
  ipv6_native = local.other_subnets[count.index].ipv6_native
  availability_zone = local.other_subnets[count.index].az

  tags = {
    Name = local.other_subnets[count.index].name
  }
}

resource "aws_default_route_table" "primary" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "${var.vpc_name}-default"
  }
}

resource "aws_route_table" "internal" {

  tags = {
    Name = "${var.vpc_name}-default"
  }
}

resource "aws_eip" "nat" {
  count = length(var.nat_azs)
}

resource "aws_nat" "nat" {
  count = length(var.nat_azs)
}

resource "aws_route_attachment" "ingress" {
  count = length(var.ingress_subnets)

  subnet_id      = aws_subnet.ingress[count.index].id
  route_table_id = aws_default_route_table.primary.id
}

resource "aws_route_attachment" "computer" {
  count = length(var.compute_subents)

  subnet_id      = aws_subnet.compute[count.index].id
  route_table_id = aws_default_route_table.internal.id
}

resource "aws_route_attachment" "other" {
  count = length(local.other_subnets)

  subnet_id      = aws_subnet.other_subnets[count.index].id
  route_table_id = aws_default_route_table.internal.id
}

resource "aws_internet_gateway" "internet_access" {
  count = var.public ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

