#############################################################################
#VPC-Creation
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_hostnames = true
  tags = {
    Name = "Load-Balancer-VPC"
  }
}
###################################################################################
#Subnet-Creation
resource "aws_subnet" "public-subnets" {
  cidr_block = cidrsubnet(var.cidr_vpc, var.bits, "${count.index}")
  availability_zone = data.aws_availability_zones.AZs.names[count.index]
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  count = length(data.aws_availability_zones.AZs.names)
  tags = {
    Name = "${var.project}-Public-${count.index + 1}"
  }
}
###################################################################################
#Egress-Rules for EC2 - Instance
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
    Name = "${var.project}-Instance-SG"
  }
}

#Resource block to add all specified ingress ports for EC2 Instance

resource "aws_security_group_rule" "Inst-SG" {
  for_each = toset(var.ingress_ports)
  type = "ingress"
  from_port = each.value
  to_port = each.value
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  ipv6_cidr_blocks = [ "::/0" ]
  security_group_id = aws_security_group.Inst-SG.id
}
#Security Group for Load-Balancer
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
    Name = "${var.project}-LB-SG"
  }
}
###################################################################################
#Internet-Gateway Creation
resource "aws_internet_gateway" "ALB-IGw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-IGW"
  }
}
##################################################################################
#Route table Creation
resource "aws_route_table" "ALB--Public--RTB" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ALB-IGw.id
  }
 tags = {
    Name = "${var.project}-Public"
  }
}
###################################################################################
#Route Table Association
resource "aws_route_table_association" "ALB--public" {
  count = "${length(aws_subnet.public-subnets.*.cidr_block)}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = aws_route_table.ALB--Public--RTB.id
}
