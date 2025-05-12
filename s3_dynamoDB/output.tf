output "s3_bucket_name" {
  value = aws_s3_bucket.terraform-microk8s.bucket
  
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
output "ecr_repository_url" {
  value = aws_ecr_repository.my_ecr_repo.repository_url
}
