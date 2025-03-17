output "instance_ip" {
  value = aws_instance.builder.public_ip
}

output "instance_id" {
  value = aws_instance.builder.id
}

output "ssh_key_location" {
  description = "Path to the SSH private key"
  value       = "${path.module}/liad_ssh_key.pem"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.liad_security_group_id.id
}