output "n8n_public_ip" {
  value       = aws_eip.n8n.public_ip
  description = "Public IP of the EC2 instance"
}

output "n8n_url" {
  value       = "https://${local.fqdn}"
  description = "HTTPS URL for n8n"
}

output "n8n_instance_id" {
  value       = aws_instance.n8n.id
  description = "Instance ID for SSM Session Manager"
}
