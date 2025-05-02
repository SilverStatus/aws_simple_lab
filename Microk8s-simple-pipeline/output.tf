output "aws_availability_zones" {
    value = data.aws_availability_zones.available.names
}

output "aws_vpc" {
    value = aws_vpc.microk8s-vpc.id
}

output "aws_subnet" {
    value = aws_subnet.public_subnet[*].id
}

output "aws_security_group" {
    value = aws_security_group.instance_sg.id
}

output "instances_details" {
    value = {
        for instance in aws_instance.microk8s-instance: 
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
