#create output from vpc module declaration in main.tf

output "spot_instance_ips" {
  value = module.ec2.k3_instance_spot_public_ips
}

output "count_on_demand_instances_ips" {
  value = module.ec2.k3s_instance_on_demand_ips
}

