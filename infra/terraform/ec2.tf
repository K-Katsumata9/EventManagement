data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  ecr_registry   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  backend_image  = "${aws_ecr_repository.backend.repository_url}:${var.backend_image_tag}"
  frontend_image = "${aws_ecr_repository.frontend.repository_url}:${var.frontend_image_tag}"
}

data "aws_caller_identity" "current" {}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name != "" ? var.ssh_key_name : null

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aws_region             = var.aws_region
    ecr_registry           = local.ecr_registry
    docker_compose_content = file("${path.module}/../../docker-compose.prod.yml")
    backend_image          = local.backend_image
    frontend_image         = local.frontend_image
    rails_master_key       = var.rails_master_key
    db_host                = aws_db_instance.main.address
    db_port                = aws_db_instance.main.port
    db_name                = var.db_name
    db_user                = var.db_username
    db_password            = var.db_password
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
