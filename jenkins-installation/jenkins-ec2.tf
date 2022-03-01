data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] 
}

resource "aws_instance" "jenkins" {
    instance_type = var.instance_type
    ami = data.aws_ami.amazon_linux.id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true
    user_data = file("init-script.sh")
    tags = {
      Name = "JenkinsMaster",
  }

    volume_tags = {
      "Name" = "JenkinsMaster-volume"
    }
}