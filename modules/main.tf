resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_hostnames = true
  tags = {
    Name = "Load-Balancer-VPC"
  }
}

resource "aws_subnet" "public-subnets" {
  cidr_block = cidrsubnet(var.cidr_vpc, var.bits, "${count.index}")
  availability_zone = data.aws_availability_zones.AZs.names[count.index]
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
#  count = data.aws_region.current.name == "ap-south-1" ? 2 : length(data.aws_availability_zones.AZs.names)
  count = length(data.aws_availability_zones.AZs.names)
  tags = {
    Name = "${var.project}-Public-${count.index + 1}"
  }
}
resource "aws_security_group" "Inst-SG" {
  name = "APP-SG"
  description = "app-acces"
  vpc_id = aws_vpc.vpc.id
  egress {
    description = ""
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = {
    Name = "Load_Balancer-APP"
  }
}

resource "aws_security_group_rule" "Inst-SG" {
#  count = length(var.ingress_ports)
  for_each = toset(var.ingress_ports)
  type = "ingress"
  from_port = each.value
  to_port = each.value
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  ipv6_cidr_blocks = [ "::/0" ]
  security_group_id = aws_security_group.Inst-SG.id
}

resource "aws_security_group" "allow" {
  name = "Allow-SG"
  description = "allow-all"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = ""
    from_port = 1
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  egress {
    description = ""
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  tags = {
    Name = "ALB-Full-Access"
  }
}

resource "aws_internet_gateway" "ALB-IGw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "ALB-IGW"
  }
}

resource "aws_route_table" "ALB--Public--RTB" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ALB-IGw.id
  }
 tags = {
    Name = "ALB-Public"
  }
}

resource "aws_route_table_association" "ALB--public" {
  count = "${length(aws_subnet.public-subnets.*.cidr_block)}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = aws_route_table.ALB--Public--RTB.id
}
