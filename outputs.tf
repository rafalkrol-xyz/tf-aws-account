output "account" {
  description = "The whole account object as described in the Terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#attributes-reference"
  value       = aws_organizations_account.account
}
