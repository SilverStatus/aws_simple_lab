output "k3_instance_spot_ids" {
  value = var.create_spot_instances ? aws_instance.k3_instance_spot[*].id : []
}

output "k3_instance_spot_public_ips" {
  value = var.create_spot_instances ? aws_instance.k3_instance_spot[*].public_ip : []
}

output "k3s_instance_on_demand_ids" {
  value = var.create_on_demand_instances ? aws_instance.k3s_instance_on_demand[*].id : []
}

output "k3_instance_on_demand_ips" {
  value = var.create_on_demand_instances ? aws_instance.k3s_instance_on_demand[*].public_ip : []
}
