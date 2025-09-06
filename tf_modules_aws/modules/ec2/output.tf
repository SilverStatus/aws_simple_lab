output "k3_instance_spot_ids" {
  value = var.create_spot_instances ? [for instance in aws_instance.k3_instance_spot : instance.id] : []
}

output "k3_instance_spot_public_ips" {
  value = var.create_spot_instances ? [for instance in aws_instance.k3_instance_spot : instance.public_ip] : []
}

output "k3s_instance_on_demand_ids" {
  value = var.create_on_demand_instances ? [for instance in aws_instance.k3s_instance_on_demand : instance.id] : []
}

output "k3s_instance_on_demand_ips" {
  value = var.create_on_demand_instances ? [for instance in aws_instance.k3s_instance_on_demand : instance.public_ip] : []
}
