provider "aws" {
  region = "ap-south-1"  # Change this to your desired AWS region
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom-vpc"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"  # Change as needed
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

# Create Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"  # Change as needed
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}

# Create Private Subnet 3
resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"  # Change as needed
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-3"
  }
}

# Optional: Output the Subnet IDs for verification
output "subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "subnet_3_id" {
  value = aws_subnet.private_subnet_3.id
}

# Create Security Group in the Correct VPC
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow SSH access in private subnet"
  vpc_id      = aws_vpc.custom_vpc.id  # Ensure the security group is in the correct VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}


# Create EC2 Instance in the Private Subnet
resource "aws_instance" "private_ec2_instance" {
  ami           = "ami-0003f8ee4b5bb5e21"  # i took window server ami
  instance_type = "m5.large"               # Adjust the instance type as needed
  subnet_id     = aws_subnet.private_subnet_1.id  # Reference to the private subnet
  
  # Configure security group to allow SSH (port 22) access
  #security_groups = [aws_security_group.private_sg.name]

  # Set the key pair for SSH access (replace with your actual key name)
  key_name = "ssh-access-key"

  tags = {
    Name = "Private-EC2-Instance"
  }

  depends_on = [aws_security_group.private_sg]  # Ensure the security group is created before the EC2 instance


  # Disable public IP for EC2 instance in a private subnet
  associate_public_ip_address = false
}


output "ec2_instance_id" {
  value = aws_instance.private_ec2_instance.id
}
