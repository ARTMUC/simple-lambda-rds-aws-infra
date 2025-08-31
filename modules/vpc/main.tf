data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet"
    Environment = var.environment
    Type = "Public"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-1"
    Environment = var.environment
    Type = "Private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-2"
    Environment = var.environment
    Type = "Private"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [var.vpc_endpoints_security_group_id]

  tags = {
    Name = "${var.project_name}-${var.environment}-ssm-endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids = [var.vpc_endpoints_security_group_id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2messages-endpoint"
    Environment = var.environment
  }
}