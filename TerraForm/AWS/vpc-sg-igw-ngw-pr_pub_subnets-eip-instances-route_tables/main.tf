provider "aws" {
  profile = var.profile
  region  = var.aws_region
}


# ----- Create VPC ----------

resource "aws_vpc" "dc1" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "dc1"
  }
}

# ------ Create Internet Gateway ------

resource "aws_internet_gateway" "dc1_igw" {
  vpc_id = aws_vpc.dc1.id
  tags = {
    Name = "dc1-igw"
  }
  
}

# ----- Create Elastic IP ------------

resource "aws_eip" "eip" {
  vpc = true
  
}

# ----------- Create Subnets ----------------

data "aws_availability_zones" "azs" {
  state = "available"
  
}

            # ----- Create Public Subnets ------------
resource "aws_subnet" "public-subnet-1a" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block = "10.10.20.0/24"
  vpc_id = aws_vpc.dc1.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-1a"
  }
  
}

resource "aws_subnet" "public-subnet-1b" {
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block = "10.10.21.0/24"
  vpc_id = aws_vpc.dc1.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-1b"
  }
  
}


            # ----- Create Private Subnets ------------
resource "aws_subnet" "private-subnet-1a" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block = "10.10.22.0/24"
  vpc_id = aws_vpc.dc1.id
  tags = {
    Name = "private-subnet-1a"
  }
  
}

resource "aws_subnet" "private-subnet-1b" {
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block = "10.10.23.0/24"
  vpc_id = aws_vpc.dc1.id
  tags = {
    Name = "private-subnet-1b"
  }
  
}


# ----------- Create NAT Gateway ---------------

resource "aws_nat_gateway" "dc1-ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.private-subnet-1b.id
  tags = {
    Name = "dc1 nat gateway"
  }
  
}

# ------------ Create Routing Tables ---------------------

resource "aws_route_table" "dc1-public-route" {
  vpc_id = aws_vpc.dc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dc1_igw.id
  }
  
  tags = {
    Name = "dc1-public-route"
  }

}

resource "aws_default_route_table" "dc1-default-route" {
  default_route_table_id = aws_vpc.dc1.default_route_table_id
  tags = {
    Name = "dc1-default-route"
  }
  
}

              #  -------- Create Routing Association --------------

resource "aws_route_table_association" "arts1a" {
  subnet_id = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.dc1-public-route.id
 
}

resource "aws_route_table_association" "arts1b" {
  subnet_id = aws_subnet.public-subnet-1b.id
  route_table_id = aws_route_table.dc1-public-route.id
 
}

resource "aws_route_table_association" "arts-p-1a" {
  subnet_id = aws_subnet.private-subnet-1a.id
  route_table_id = aws_default_route_table.dc1-default-route.id
 
}

resource "aws_route_table_association" "arts-p-1b" {
  subnet_id = aws_subnet.private-subnet-1b.id
  route_table_id = aws_default_route_table.dc1-default-route.id
 
}

# --------------Create Security Group------------------------------


resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.dc1.id

  ingress {
    description = "web from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}


# --------------- Create Instance ----------------------------------

resource "aws_instance" "example" {
  ami           = var.aws_amis[var.aws_region]
  instance_type = var.instance_type
  tags = {
      # Name = "Example"
      Name = var.instance_name
  }
  count = var.instance_count
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id = aws_subnet.public-subnet-1a.id
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<html>Hello World from web 1<br>public-ipv4 is `curl http://169.254.169.254/latest/meta-data/public-ipv4`</html> " > /var/www/html/index.html
    EOF
}

resource "aws_instance" "example2" {
  ami           = var.aws_amis[var.aws_region]
  instance_type = var.instance_type
  tags = {
      # Name = "Example"
      Name = var.instance_name
  }
  count = var.instance_count
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id = aws_subnet.public-subnet-1b.id
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<html>Hello World from web 1<br>public-ipv4 is `curl http://169.254.169.254/latest/meta-data/public-ipv4`</html> " > /var/www/html/index.html
    EOF
}