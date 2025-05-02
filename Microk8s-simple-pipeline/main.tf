# Fetch available AZs in the current region (makes code region-agnostic)
data "aws_availability_zones" "available" {
  state = "available"  # Only consider AZs that can provision resources
}

resource "aws_vpc" "microk8s-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
    Environment = "Terraform"
    Project = "${var.project_name}"
  }
}

