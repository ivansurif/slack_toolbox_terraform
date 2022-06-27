Cognite - SKF Cenit - Terraform
===


The purpose of this repository is to configure the infrastructure for the Cognite SKF Cenit project. 
The project uses a separate Github Organisation, `cognite-skf-cenit` and Azure AD and Subscription, 
`SKF Cenit By Cognite` and `Azure Companion Project - SKF Cenit - SKF Tenant` respectively.

The repository handles the creation, management and destruction of all Azure resources within these subscriptions. 

## Before using this repo

These resources / values need to be created:

### Azure account used to store resources, not AAD

A <b>Subscription</b> needs to be created manually in the Azure Tenant prior to executing this code. 

A **Storage Account** where Terraform state will be stored also needs to be created prior to using this repo. 
The name of the storage account is referenced (and needs to be updated) in multiple files throughout this repo, 
in variable `storage_account_name`. The storage account, in turn, needs to be created within a **Resource Group**, 
also created manually, which name does not need to be updated in this repo.
No need to create tags when creating the Resource Group.

Lastly, a **Storage Container** needs to be created within the previously created Storage Account. 
The container shall be named `tfstate`. If choosing a different name, the references to the Storage Container 
within this code need to be updated to match the selected name.

Once a Resource Group and Storage Accounts are created, and the Access Key set in Secret ARM_ACCESS_KEY,  
Terraform takes it from there, including the creation of the Storage Container within that Storage Account 
where the Terraform state file will be stored.

### GitHub
Several secrets need to be set at repo level in order for the workflows to run: they are listed in the GH workflow.


## Structure

A Github Actions Workflow automates the Terraform Plan and Apply. And directory containing a `.tf` file is considered a Terraform Workspace, and the action will attempt to provide a Plan for that workspace.

As a default, all Terraform workspaces should be under the `terraform` folder and then are organised by provider, ie. `azure` and `github`.

A `project_vars` workspace exists in the `terraform` directory. This is used to provide output to both providers, when necessary.

The infrastructure built by Terraform is split into two different modules: 

* terraform/azure/tier0/resources builds:
  * Resource Group
  * Storage Account
  * Container Registry
  * Container Instance
  * Key Vault

* terraform/azure/tier1/function_apps builds the Function Apps


## Deployment Notes

It is not possible to create state in one PR that is referenced for the first time in the same PR. ie You can't do staggered Plan and Apply. You can however make changes to multiple workspaces at the same time, as long as they don't rely on the other.

The `plan` stage will provide the intended infra changes as a comment in the PR comments thread. Read this carefully before proceeding.

The `apply` stage requires an approval from one of the configured approvers.

Having successfully applied the infra changes, the changes can be approved and merged into the `main` branch.

## Inviting a new User to the Azure AD Tenant:

⚠️ **This is only applicable if AAD is stored in the same Subscription as the remaining resources, which is not the case
for SKF Cenit project. I leave it documented here because it might become handy at some point**

1. Create a new branch
1. In `terraform/azure/tier0/guest_users/users.tf` create an invite for the new user by adding them to the `users` set. The format is ` display_name : email_address`
1. Run `terraform fmt --recursive=true` to ensure formatting is correct
1. Add the changes and create a PR
1. Check the Plan, and have someone on the `infra-team-push` approve and run the Apply
1. If the Apply is successful, have the changes approved and merged to the main branch

## Inviting a User to the Github Org

ℹ️ **This still applies even if the AAD Subscription is not the same as the one holding the resources**

As a prerequisite to this, the user must be in the Azure AD Tenant, so the previous section should be completed.

1. Create a new branch
1. In `terraform/azure/tier0/iam/github_users.tf` add the previously invited users email to the `github_users` list
1. In `terraform/github/teams/users.tf` add the user to the `github_users` set
1. Run `terraform fmt --recursive=true` to ensure formatting is correct
1. Add the changes and create a PR
1. Check the Plan, and have someone on the `infra-team-push` approve and run the Apply
1. If the Apply is successful, have the changes approved and merged to the main branch
1. Direct the new user to `https://github.com/orgs/cognite-skf-cenit/sso` to complete the authorization process
