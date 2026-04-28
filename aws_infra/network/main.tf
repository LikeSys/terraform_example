# main.tf

# VPC
resource "aws_vpc" "aws08-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}vpc"
  }
}

# Subnets
resource "aws_subnet" "aws08-public-subnet" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws08-vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.prefix}public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "aws08-private-subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws08-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.prefix}private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "aws08-igw" {
  vpc_id = aws_vpc.aws08-vpc.id
  tags = {
    Name = "${var.prefix}igw"
  }
}

# Elastic IP
resource "aws_eip" "aws08-nat-eip" {
  domain = "vpc"
  tags = {
    Name = "${var.prefix}nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "aws08-nat-gw" {
  allocation_id = aws_eip.aws08-nat-eip.id
  subnet_id     = aws_subnet.aws08-public-subnet[0].id
  tags = {
    Name = "${var.prefix}nat-gw"
  }
}

# Route Table and Routing Rules
# 1. 퍼블릭 라우트 테이블 (IGW로 향함)
resource "aws_route_table" "aws08-public-rt" {
  vpc_id = aws_vpc.aws08-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws08-igw.id # NAT가 아니라 IGW입니다!
  }

  tags = {
    Name = "${var.prefix}public-route-table"
  }
}

# 2. 프라이빗 라우트 테이블 (NAT GW로 향함)
resource "aws_route_table" "aws08-private-rt" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.aws08-vpc.id # vpc_id 추가

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws08-nat-gw.id # IGW가 아니라 NAT GW입니다!
  }

  tags = { # = 추가
    Name = "${var.prefix}private-rt-${count.index + 1}"
  }
}

# 3. 프라이빗 라우트 테이블 연결
resource "aws_route_table_association" "aws08-private-rt-association" { 
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.aws08-private-subnet[count.index].id
  route_table_id = aws_route_table.aws08-private-rt[count.index].id
}

# Security Group 생성 - SSH-SG, HTTP-SG
resource "aws_security_group" "aws08-ssh-sg" {
  name = "${var.prefix}ssh-sg"
  vpc_id = aws_vpc.aws08-vpc.id
  description = "Allow SSH Access"
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aws08-http-sg" {
  name = "${var.prefix}http-sg"
  vpc_id = aws_vpc.aws08-vpc.id
  description = "Allow HTTP Access"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}