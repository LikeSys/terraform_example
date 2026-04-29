# aws_infra/network/main.tf

# VPC
resource "aws_vpc" "aws08_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Subnets
resource "aws_subnet" "aws08_public_subnet" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws08_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "aws08_private_subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.aws08_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "aws08_igw" {
  vpc_id = aws_vpc.aws08_vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Elastic IP
resource "aws_eip" "aws08_nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "aws08_nat_gw" {
  allocation_id = aws_eip.aws08_nat_eip.id
  subnet_id     = aws_subnet.aws08_public_subnet[0].id
  tags = {
    Name = "${var.prefix}-nat-gw"
  }
}

# Route Table and Routing Rules
# 1. 퍼블릭 라우트 테이블 (IGW로 향함)
resource "aws_route_table" "aws08_public_rt" {
  vpc_id = aws_vpc.aws08_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws08_igw.id
  }

  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "aws08_public_rt_association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.aws08_public_subnet[count.index].id
  route_table_id = aws_route_table.aws08_public_rt.id
}

# 2. 프라이빗 라우트 테이블 (NAT GW로 향함)
resource "aws_route_table" "aws08_private_rt" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.aws08_vpc.id # vpc_id 추가

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws08_nat_gw.id
  }

  tags = { # = 추가
    Name = "${var.prefix}-private-rt-${count.index + 1}"
  }
}

# 3. 프라이빗 라우트 테이블 연결
resource "aws_route_table_association" "aws08_private_rt_association" { 
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.aws08_private_subnet[count.index].id
  route_table_id = aws_route_table.aws08_private_rt[count.index].id
}

# Security Group 생성 - SSH-SG, HTTP-SG
resource "aws_security_group" "aws08_ssh_sg" {
  name = "${var.prefix}-ssh-sg"
  vpc_id = aws_vpc.aws08_vpc.id
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

  tags ={
    Name = "${var.prefix}-ssh-sg"
  }
}

resource "aws_security_group" "aws08_http_sg" {
  name = "${var.prefix}-http-sg"
  vpc_id = aws_vpc.aws08_vpc.id
  description = "Allow HTTP Access"
  
  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags ={
    Name = "${var.prefix}-http-sg"
  }
}