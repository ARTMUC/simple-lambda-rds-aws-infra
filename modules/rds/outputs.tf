output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "port_forwarding_command" {
  description = "Command for port forwarding to RDS via bastion"
  value       = "aws ssm start-session --target <BASTION_INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters 'portNumber=3306,localPortNumber=3306'"
}

output "secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "secret_name" {
  description = "Name of the database password secret"
  value       = aws_secretsmanager_secret.db_password.name
}