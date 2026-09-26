variable "aws_region" {
  description = "デプロイ先リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "eventmanagement"
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "EC2用パブリックサブネットのCIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "RDS用プライベートサブネットのCIDR（異なるAZに2つ）"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ec2_instance_type" {
  description = "EC2インスタンスタイプ"
  type        = string
  default     = "t3.small"
}

variable "rds_instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "eventmanagement_production"
}

variable "db_username" {
  description = "DBマスターユーザー名"
  type        = string
  default     = "eventmanagement"
}

variable "db_password" {
  description = "DBマスターパスワード"
  type        = string
  sensitive   = true
}

variable "rails_master_key" {
  description = "Rails credentials復号用のmaster key（backend/config/master.keyの値）"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "EC2 SSH用の既存キーペア名（空文字の場合SSHキーは設定しない）"
  type        = string
  default     = ""
}

variable "ssh_allowed_cidr" {
  description = "SSH接続を許可するCIDR（自分のIP/32を推奨）"
  type        = string
  default     = "0.0.0.0/0"
}

variable "backend_image_tag" {
  description = "backendコンテナのイメージタグ（ECRリポジトリへの事前pushが必要）"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "frontendコンテナのイメージタグ（ECRリポジトリへの事前pushが必要）"
  type        = string
  default     = "latest"
}
