data "aws_ami" "jajelociraptor_ubuntu_image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jajelociraptor_instance" {
  ami           = data.aws_ami.jajelociraptor_ubuntu_image.image_id
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }
  iam_instance_profile = aws_iam_instance_profile.jajelociraptor_ec2_instance_profile.name

  user_data = templatefile("${path.module}/install_script.sh.tpl", {
    s3_name        = aws_s3_bucket.jajelociraptor_s3_bucket.bucket,
    admin_username = var.admin_username,
    admin_email    = var.admin_email,
    aws_region     = data.aws_region.aws_region_information.name
  })

  tags = {
    Name = var.name
  }

  vpc_security_group_ids = [aws_security_group.jajelociraptor_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
