# Set a provider
provider "aws" {
  region = "eu-west-1"
}

# create vpc
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.name
  }
}

# Create security group
resource "aws_security_group" "app_security" {
  name        = var.name
  description = "Allow port 80"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "app_IG" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.name} - IG"
  }
}

# Route table
resource "aws_route_table" "app_route" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_IG.id
  }

  tags = {
  # this tag calls the variable and interpolates with the word route
    Name = "${var.name} - route"
  }
}

# Route table assocations
resource "aws_route_table_association" "app_route_association" {
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route.id
}

# Create subnet
resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = var.name
  }
}

# Send template sh file
data "template_file" "app_init" {
  template = "${file("./scripts/init_script.sh.tpl")}"
}

# Launch an instance

resource "aws_instance" "app_init" {
  ami           = var.ami
  subnet_id     = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_security.id]
  instance_type = "t2.micro"
  associate_public_ip_address = true
  user_data = data.template_file.app_init.rendered
  tags = {
    Name = var.name
  }
}
