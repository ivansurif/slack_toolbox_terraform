Terraform Deployment Template
===

## Repo setup

1. Create these **secrets** in your repo:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `ARM_ACCESS_KEY` => See explanation below

2. Make sure that your `GH Actions` workflow permissions are permissive: _Settings > Actions > Workflow permissions >_ 
select `Read & Write permissions`

## Azure Setup

- An Azure **Tenant** is required. It's ID needs to be set in GitHub Secret `ARM_TENANT_ID`.


- A **Subscription** needs to exist in the Azure Tenant prior to executing this code. 
It's ID needs to be stored in a GitHub Secret called `ARM_SUBSCRIPTION_ID`.

**Note**: Subscriptions need to have resource providers registered (enabled) in order for these to be used. 
If you attempt to build a resource which provider is not enabled, you will get a `MissingSubscriptionRegistration` error. 
This error is easy to fix, and the message is self explanatory. But you need admin access to the tenant in order to 
enable (register) resource providers (i.e., fixing this error). Sample error below:


`2022-06-30T18:44:03.1472586Z Error: creating Container Registry "REGISTRY_NAME_HERE" (Resource Group "common-services"): containerregistry.RegistriesClient#Create: Failure sending request: StatusCode=409 -- Original Error: Code="MissingSubscriptionRegistration" Message="The subscription is not registered to use namespace 'Microsoft.ContainerRegistry'. See https://aka.ms/rps-not-found for how to register subscriptions." Details=[{"code":"MissingSubscriptionRegistration","message":"The subscription is not registered to use namespace 'Microsoft.ContainerRegistry'. See https://aka.ms/rps-not-found for how to register subscriptions.","target":"Microsoft.ContainerRegistry"}]`

**Note**: Terraform erros in GH Actions can by pretty cryptic. 
Therefore [enabling debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging) 
is very recommendable (and will esure that you catch errors like the one above).

**Note** As explained [here](https://groups.google.com/g/terraform-tool/c/MWSA-_1L9IM/m/IOZffHoXBAAJ), 
_Terraform will only try to manipulate resources that are in the state file (ie they were created by TF in the first place, or they were imported into state). It ignores everything else. Also, `terraform plan` is pretty trustworthy, especially the last line where it details how many resources will be changed, deleted, or created. If those all say zero, then you are in a safe place._


<br>

### The following resources need to be created <u>_manually_</u>:  
The reason is that state file is stored in Azure itself. So the creation of the storage group, account and container
where Terraform will be able to create and update the file need to precede the deployment of the resources through this repo.

Their names are referenced in file `provider.tf`:

```
terraform {
  backend "azurerm" {
    storage_account_name = "sandbox4terraform"
    container_name       = "tfstate"
    key                  = "azure.tier0.common_services"
    # Access Key set as environment variable ARM_ACCESS_KEY
  }
  (...)
```

And, as mentioned in the code comment, repo secret `ARM_ACCESS_KEY` is necessary for the repo to be able to write to
that container.


The code in the repo runs assuming these resources exist, and will return an error when deploying if they don't.</br>


- A **Resource Group**


- A **Storage Account**  
After creating the Storage Account, copy either of its **Access Keys** from the Azure UI. 
Store its value in a **GitHub Repository Secret** named `ARM_ACCESS_KEY`


- Lastly, a **Storage Container** needs to be created within the previously created Storage Account. 
The container shall be named `tfstate` for convenience. 


- An **App Registration** needs to be created in Azure Active Directory. Copy and set it's ID in GitHub Secret
 `ARM_CLIENT_ID`. Create a Secret and set its value in GitHub Secret `ARM_CLIENT_SECRET`.  
This App Registration needs to be set as Owner of the Subscription in order to be able to manage resources.

