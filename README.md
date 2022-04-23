# Terraform AWS Account (Organizations)

## Overview

This is a parametrized [Terraform module](https://learn.hashicorp.com/tutorials/terraform/module)
for creating [an AWS account within your AWS Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create.html).

## Prerequisites

* [AWS IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) with adequate privileges
* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) that's properly [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
* [Terraform](https://www.terraform.io/)
  * NB you can use [`tfswitch`](https://tfswitch.warrensbox.com/) to manage different versions of Terraform

### Prerequisites for pre-commit-terraform

**a)** dependencies

The [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) util requires the latest versions of the following dependencies:

* [pre-commit](https://pre-commit.com/#install)
* [terraform-docs](https://github.com/terraform-docs/terraform-docs)
* [tflint](https://github.com/terraform-linters/tflint)
* [tfsec](https://github.com/aquasecurity/tfsec)
* [terrascan](https://github.com/accurics/terrascan)

On macOS, you can install the above with [brew](https://brew.sh/):

```bash
brew install pre-commit terraform-docs tflint tfsec terrascan
```

**b)** usage

The tool will run automatically before each commit if [git hooks scripts](https://pre-commit.com/#3-install-the-git-hook-scripts) are installed in the project's root:

```bash
pre-commit install
```

For a manual run, execute the below command:

```bash
pre-commit run -a
```

**NB the configuration file is located in `.pre-commit-config.yaml`**

## Usage

```terraform
### ORGANIZATION AND ORGANIZATIONAL UNITS - START
# After the AWS docs: "An entity that you create to consolidate your AWS accounts so that you can administer them as a single unit."
module "root" {
  source               = "git@github.com:rafalkrol-xyz/tf-aws-organizations.git?ref=v1.0.0"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
  ]
  organizational_units = [
    {
      name = "core"
    },
    {
      name = "workloads"
    },
  ]
}
### ORGANIZATION AND ORGANIZATIONAL UNITS - END


### ACCOUNTS - START
locals {
  role_name = "AdminAssumeRole"
}

module "log-archive" {
  source    = "git@github.com:rafalkrol-xyz/tf-aws-account.git?ref=v1.0.0"
  name      = "log-archive"
  email     = "youremailaddress+log-archive@gmail.com"
  parent_id = module.root.ou_ids["core"]
  role_name = local.role_name # NB you won't be able to change this role name via Terraform once created
}

module "prod" {
  source    = "git@github.com:rafalkrol-xyz/tf-aws-account.git?ref=v1.0.0"
  name      = "prod"
  email     = "youremailaddress+prod@gmail.com"
  parent_id = module.root.ou_ids["workloads"]
  role_name = local.role_name # NB you won't be able to change this role name via Terraform once created
}
### ACCOUNTS - END
```

### Note on tags

[Starting from AWS Provider for Terraform v3.38.0 (with Terraform v0.12 or later onboard), you may define default tags at the provider level, streamlining tag management](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider).
The functionality replaces the now redundant per-resource tags configurations, and therefore, this module has dropped the support of a `tags` variable.
Instead, set the default tags in your parent module:

```terraform
### PARENT MODULE - START
locals {
  tags = {
    key1   = "value1"
    key2   = "value2"
    keyN   = "valueN"
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = local.tags
  }
}

# NB the default tags are implicitly passed into the module: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags
module "log-archive" {
  source    = "git@github.com:rafalkrol-xyz/tf-aws-account.git?ref=v1.0.0"
  name      = "log-archive"
  email     = "youremailaddress+log-archive@gmail.com"
  parent_id = module.root.ou_ids["core"]
  role_name = local.role_name # NB you won't be able to change this role name via Terraform once created
}
### PARENT MODULE - END
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
