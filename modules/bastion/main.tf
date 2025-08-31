data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.project_name}-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.project_name}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id = var.private_subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql htop
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
    Environment = var.environment
  }
}