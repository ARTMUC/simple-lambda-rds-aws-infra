output "instance_id" {
  description = "ID of the bastion host"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "session_manager_connection_command" {
  description = "Command to connect to bastion via Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id}"
}