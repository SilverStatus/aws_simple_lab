output "aws_availability_zones" {
    value = data.aws_availability_zones.available.names
}

output "aws_vpc" {
    value = aws_vpc.k3s-vpc.id
}

output "aws_subnet" {
    value = aws_subnet.public_subnet[*].id
}

output "aws_security_group" {
    value = aws_security_group.instance_sg.id
}

output "instances_details_spot" {
    value = {
        for instance in aws_instance.k3s_instance_spot: 
        instance.id => {
            public_ip = instance.public_ip
            private_ip = instance.private_ip
            ami_id = instance.ami
            instance_type = instance.instance_type
            availability_zone = instance.availability_zone
            tags = instance.tags
            }  
    }
}
output "instances_details_bastion" {
    value = {
        for instance in aws_instance.bastion_instance: 
        instance.id => {
            public_ip = instance.public_ip
            private_ip = instance.private_ip
            ami_id = instance.ami
            instance_type = instance.instance_type
            availability_zone = instance.availability_zone
            tags = instance.tags
            }  
    }
}

output "instance_public_ips" {
    value = {
        spot_instance = aws_instance.k3s_instance_spot[*].public_ip
        bastion_instance = aws_instance.k3s_bastion[*].public_ip
    }

}

output "alb_dns_name" {
    value = aws_lb.k3s_lb.dns_name
  
}

