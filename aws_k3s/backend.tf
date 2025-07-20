terraform {
  backend "s3" {
    bucket         = "terraform-101001"
    key            = "k3s_backend.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    
  }
}