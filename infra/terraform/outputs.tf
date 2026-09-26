output "ec2_public_ip" {
  description = "EC2のパブリックIP（ブラウザでこのIPにアクセスする）"
  value       = aws_instance.app.public_ip
}

output "rds_endpoint" {
  description = "RDSのエンドポイント"
  value       = aws_db_instance.main.address
}

output "ecr_backend_repository_url" {
  description = "backendイメージをpushするECRリポジトリURL"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "frontendイメージをpushするECRリポジトリURL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_login_command" {
  description = "ECRへのdocker loginコマンド"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
