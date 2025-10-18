output "s3_bucket_name" {
  value = aws_s3_bucket.terraform-microk8s.bucket
  
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
# output "ecr_repository_url" {
#   value = aws_ecr_repository.my_ecr_repo.repository_url
# }


output "user_name" {
  value       = aws_iam_user.git_user.name
  description = "IAM user name"
}

output "user_arn" {
  value       = aws_iam_user.git_user.arn
  description = "IAM user ARN"
}

output "access_key_id" {
  value       = aws_iam_access_key.git_user_key.id
  description = "Access key ID"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.git_user_key.secret
  description = "Secret access key"
  sensitive   = true
}

