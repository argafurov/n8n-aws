# n8n on EC2 with Docker, nginx, Let's Encrypt and SSM

This deploys:

- EC2 (Ubuntu, eu-central-1)
- Docker + docker-compose
- Local Postgres + n8n
- nginx reverse proxy
- Let's Encrypt TLS for `https://n8n.example.com`
- **No SSH** – access via **SSM Session Manager**

## Prerequisites

1. AWS account + IAM user with permissions to:
   - EC2, VPC, EIP, Route 53, IAM, SSM
2. Domain `example.com` in Namecheap.
3. Public hosted zone in Route 53 for `example.com` and Namecheap nameservers pointing to AWS.
4. EC2 key pair created (used only as metadata; SSH port is closed).
5. AWS CLI v2 installed and `aws configure` done (with region `eu-central-1`).

## Structure

```text
terraform/   # infrastructure (VPC, EC2, EIP, Route53, IAM role for SSM)
cloud-init/  # user_data script (installs docker, nginx, certbot, n8n)
