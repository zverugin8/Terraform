- [Problem to Be Solved](task_azure.md#problem-to-be-solved)
  * [Explanation of the Solution](task_azure.md#explanation-of-the-solution)
  * [PRE-REQUISITES](task_azure.md#pre-requisites)
- [Creating Infrastructure](task_azure.md#creating-infrastructure)
  * [TASK 1 - Creating Virtual Network](task_azure.md#task-1-creating-virtual-network)
  * [TASK 2 - Create resources for SSH Authentication](task_azure.md#task-2-create-resources-for-ssh-authentication)
  * [TASK 3 - Create a Storage account with a Storage Container](task_azure.md#task-3-create-a-storage-account-with-a-storage-container)
  * [TASK 4 - Create IAM resources](task_azure.md#task-4-create-iam-resources)
  * [TASK 5 - Create a Network Security Group](task_azure.md#task-5-create-a-network-security-group)
  * [TASK 6 - Form TF Output](task_azure.md#task-6-form-tf-output)
  * [TASK 7 - Configure a remote data source](task_azure.md#task-7-configure-a-remote-data-source)
  * [TASK 8 - Create Virtual Machine/Scale Set/Load Balancer](task_azure.md#task-8-create-virtual-machinescale-setload-balancer)
- [Working with Terraform state](task_azure.md#working-with-terraform-state)
  * [TASK 9 - Move state to a storage container](task_azure.md#task-9-move-state-to-a-storage-container)
  * [TASK 10 - Move resources](task_azure.md#task-10-move-resources)
  * [TASK 11 - Import resources](task_azure.md#task-11-import-resources)
  * [TASK 12 - Use data discovery](task_azure.md#task-12-use-data-discovery)
- [Advanced tasks](task_azure.md#advanced-tasks)
  * [TASK 13 - Expose node output with nginx](task_azure.md#task-13-expose-node-output-with-nginx)
  * [TASK 14 - Modules](task_azure.md#task-14-modules)
  


# Problem to Be Solved in This Lab
 This lab shows you how to use Terraform to create infrastructure in Azure including scaling sets, virtual network, subnets, network security groups and IAM managed identity. Each virtual machine will report its data to a specified storage container on startup. This task is binding to real production needs – for instance developers could request virtual machines with ability to writing debug information to a storage container.

 
### Explanation of the Solution 
You will use Terraform with Azure provider to create 2 separate Terraform configurations:
 1) Base configuration
 2) Compute configuration
After you’ve created configuration, we will work on its optimization like using data driven approach and creating modules.


## PRE-REQUISITES
1. Fork current repository. A fork is a copy of a project and this allows you to make changes without affecting the original project.
2. All actions should be done under your fork and Terraform gets it context from your local clone working directory:
    - Install Azure CLI (for Linux) or Azure PowerShell module (for Windows).
    - Perform authentication with command `az login` or `Connect-AzAccount` (for PowerShell)
    - Change current directory to `/tf-epam-lab/base` folder and create `root.tf` file. 
    - Add a `terraform {}` empty block to this file. Create an Azure provider block inside `root.tf`.

**Hint**: There are other ways to authenticate terraform provider before the usage. Refer to [this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) document for details.

Run `terraform init` to initialize your configuration. 
Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to ensure that there are no changes.

Please use **underscore** Terraform resources naming, e.g. `my_resource` instead of `my-resource`.

3. Change current directory  to `~/tf-epam-lab/compute` and repeat the steps in [2].

You are ready for the lab!

# Creating Infrastructure
## TASK 1 - Creating Virtual Network
Change current directory  to `~/tf-epam-lab/base`

Create a network stack for your infrastructure:

- **Resource Group**: `name={StudentName}-{StudentSurname}-01`
-	**Virtual Network**: `name={StudentName}-{StudentSurname}-01-vnet-us-central`, `cidr=10.10.0.0/16`, `location="centralus"`
-	**Subnets**: `name={StudentName}-{StudentSurname}-01-subnet`, `cidr=10.10.1.0/24`)

**Hint**: A local value assigns a name to an expression, so you can use it multiple times within a module without repeating it. 

Store all resources from this task in the `network.tf` file.
Store all locals in `locals.tf`.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- Push *.tf configuration files to git

## TASK 2 - Create resources for SSH Authentication

Ensure that the current directory is `~/tf-epam-lab/base`

Create a custom ssh key-pair to access your virtual machines:

- Create your ssh key pair.
- Create a `variables.tf` file with empty variable `ssh_key` but with the following description `Provides custom public ssh key`. 
- Create a `ssh.tf` file for SSH resources. Use `ssh_key` variable as a public key source.
- Create `azurerm_ssh_public_key` resource with the name `epam-tf-ssh-key`. 
  
  **Note** : Despite the fact that a public SSH key is not a secret, in terms of this lab you should not store it in the repository. The public key should be passed as an environment variable:
  
    `export TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"`

  Never store you secrets inside the code!

- Run `terraform plan` and observe the output.

Equip all possible resources with following tags or labels:
  - `Terraform=true`, 
  - `Project=epam-tf-lab`
  - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- All resources created as expected (check Cloud WebUI)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline (if a pipeline configured)

## TASK 3 - Create a Storage account with a Storage Container

Ensure that the current directory is  `~/tf-epam-lab/base`

Create a storage account. For this storage account create a storage container as the storage for your infrastructure:

-	Create `storage.tf`. Name your storage account "epamazuretflab${random_string.my_numbers.result}" to provide it with partition unique name. See [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) documentation for details.
-	Set `Public access level` for the new storage container private. Never share your data to the whole world!

Equip a storage account with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- Push *.tf configuration files to git

## TASK 4 - Create IAM resources
Ensure that the current directory is  `~/tf-epam-lab/base`

Create IAM resources:

- **User Managed Identity** (`name={StudentName}-{StudentSurname}-01`)
-	**Role** (`name={StudentName}-{StudentSurname}-01`) with write permission for storage account created on the previous stage (`name=storage-write-epam-azure-tf-lab-${random_string.my_numbers.result}`).
- Assign the Role to the User Managed Identity

Store all resources from this task in the `iam.tf` file.

Equip all possible resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- Push *.tf configuration files to git

## TASK 5 - Create a Network Security Group
Ensure that the current directory is  `~/tf-epam-lab/base`

Create the Network security group with name `lab-inbound`.

For the created network security group create rules:
-	`name=http-inbound`, `destination_port_range=80`, `source_address_prefix="your_IP or EPAM_office-IP_range"`, `destination_address_prefix="subnet address range"`, `description="allows http access from safe IP-range to the subnet"`.
-	`name=ssh-inbound`, `destination_port_range=22`, `source_address_prefix="your_IP or EPAM_office-IP_range"`, `destination_address_prefix="subnet address range"`, `description="allows ssh access from safe IP-range"`. 

**Hint:** `network_security_group_name` is an attribute of [azurerm_network_security_rule resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule). For details about how to configure securitygroups for loadbalancer see [documentation] (https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)


Store all resources from this task in the `network_security.tf` file.

Equip all possible resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying  your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- Push *.tf configuration files to git

## TASK 6 - Form TF Output
Ensure that current directory is  `~/tf-epam-lab/base`

Create outputs for your configuration:

- Create `outputs.tf` file.
- Following outputs are required: `network_name`, `subnet_ids`[set of strings], `network_security_group_id`, `storage_container_name`,`storage_account_name`, `user_managed_identity_id`.

Store all resources from this task in the `outputs.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready. You can update outputs without using `terraform apply` - just use the `terraform refresh` command.

### Definition of DONE:

- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 7 - Configure a remote data source

Learn about [terraform remote state data source](https://www.terraform.io/docs/language/state/remote-state-data.html).

! Change the current directory to  `~/tf-epam-lab/compute`
! Copy `root.tf` from `~/tf-epam-lab/base` to `~/tf-epam-lab/compute`

Add remote state resources to your configuration to be able to import output resources:

-	Create a data resource for base remote state. (backend="local")

Store all resources from this task in the `data.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 8 - Create Virtual Machine/Scale Set/Load Balancer

Ensure that the current directory is  `~/tf-epam-lab/compute`

Create an init script with User Data.

Getting Virtual Machine Metadata:
```
VIRTUAL_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
RESOURCE_ID=$(replace this text with request virtual machine id from metadata e.g. using curl)
```

A User Data init bash script which should get 2 parameters on virtual machine start-up and send it to a storage container as a text file with resource_id as its name.

Command to send text a storage container (**use data rendering to pass the storage container to this script**):
```
This message was generated on virtual machine {RESOURCE_ID} with the following UUID {VIRTUAL_MACHINE_UUID}
echo "This message was generated on virtual machine ${INSTANCE_ID} with the following UUID ${VIRTUAL_MACHINE_UUID}" | azcopy copy - 'https://{AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/{STORAGE_CONTAINER_NAME}'
```

Create resources:
- Create `azurerm_public_ip` resource (`name="epam-azure-tf-lab"`)
- Create `azurerm_lb` resource (`name="epam-azure-tf-lab"`, with `frontend_ip_configuration` with reference on the created public IP address)
- Create `azurerm_lb_backend_address_pool` resource  with reference on the created load balancer

- Create an `azurerm_linux_virtual_machine_scale_set` resource. (`name="epam-azure-tf-lab"`,`instances=2`,`sku="Standard_F2"`, `custom_data=base64encode("{init_script_file}")`, source_image_reference with `publisher="Canonical"`, `offer="UbuntuServer"`, `sku="20.04-LTS"`, `version="latest"`). The network interface of future virtual machines should be in the previously created subnet with the previosly created network security group. Authentication should be through created SSH key. This scale set should be a part of the previosly cretaed backend address pool. **Note** The virtual machines in the scale set should have assigned the identity which was created in the task 5


- Create `azurerm_lb_probe` (`name="epam-azure-tf-lab"`, `protocol="Http"`, `port=80`, `request_path="/"`)
- Create `azurerm_lb_rule` (`protocol="Tcp"`, `frontend_port=80`, `backend_port=80`) with reference to the previosly created frontend IP configuration name, IDs of the backend address pool and probe ID.

Store all resources from this task in the `application.tf` file.

Equip all possible resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate` and `terraform fmt` to check if your configuration valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

As a result virtual machines should be launched by the scale set and a new file should be created in your storage container. 

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- After a new instance launch, a new text file appears in the storage container storage with the appropriate text.
- Push *.tf configuration files to git
    
# Working with Terraform state

**Mandatory**: Please do not proceed to TASKs 9-14 until your have finished previous tasks. Once completed please remove .gitlab-ci.yml from your repository. 

## TASK 9 - Move state to a storage container

Hint: Create a new storage account (`name=epamazurelab${random_string}`) and then a storage container (`name=epam-azure-tf-state`). There are multiple ways to do this, including Terraform and ARM. But
please just create both resources by a hands in Azure Portal. Those resources will be out of our IaC approach as they will never be recreated.

Learn about [terraform backend in Azure storage container](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)

Refine your configurations:

- Refine `base` configuration by moving local state to a storage container.
- Refine `compute` configuration by moving local state to a storage container.

Do not forget to change the path to the remote state for `compute` configuration.

Run `terraform validate` and `terraform fmt` to check if your modules valid and fits to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.

## TASK 10 - Move resources

Learn about [terraform state mv](https://www.terraform.io/docs/cli/commands/state/mv.html) command

You are going to move previously created resource(SSH Key) from `base` to `compute` state.
Hint: Keep in mind that there are 3 instances: Azure resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Move resource" is moving it between states. Moreover to make it work you should delete said resource from source configuration and add it to the destination configuration (this action is not automated).

- Move the Azure SSH public Key resource from the `base` state to the `compute` using `terraform state mv` command.
- Update both configurations according to this move.
- Run `terraform plan` on both configurations and observe the changes. Hint: there should not be any changes detected (no resource creation or deletion in case of correct resource move).

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.

### Definition of DONE:

- Terraform moved resources with no errors
- Azure resources are NOT changed (check Azure Portal)

## TASK 11 - Import resources

Learn about the [terraform import](https://www.terraform.io/docs/cli/import/index.html) command.

You are going to import a new resource (Resource group) to your state.
Hint: Keep in mind that there are 3 instances: Azure resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Importing a resource" is importing its attributes into a Terraform state. Then you have to add said resource to the destination configuration (this action is not automated).

- Create a User Managed Identity in Azure Portal (`name="test-import"`).
- Add a new resource `azurerm_user_assigned_identity` `test-import` to the `compute` configuration.
- Run `terraform plan` to see your changes but do not apply changes.
- Import `test-import` User Managed Identity to the `compute` state.
- Run `terraform plan` again to ensure that import was successful.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.
If applicable all resources should be tagged with following tags:
- `Terraform=true`,
- `Project=epam-tf-lab`.
If applicable all resources should be defined with the provider alias.

- Terraform imported resources with no errors
- Azure resources are NOT changed (check Azure Portal)

## TASK 12 - Use data discovery
Learn about [terraform data sources](https://www.terraform.io/docs/language/data-sources/index.html) and [querying terraform data sources](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_BLOG&utm_offer=ARTICLE_PAGE).

In this task we are going to use a data driven approach instead to use remote state data source.

#### base configuration
Change current directory to `~/tf-epam-lab/base`

Refine your configuration :
- Use a data source to request a Subscription ID, 
- Use a data source to request a Client ID of the current user.

Store all resources from this task in the `data.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes. You can also use `terraform refresh`.
If applicable all resources should be defined with the provider alias.

Apply your changes when ready.

# Advanced tasks

## TASK 13 - Expose node output with nginx

Ensure that the current directory is  `~/tf-epam-lab/compute`

Change init User Data script (Task 8) as follows:

-   Nginx binary should be installed on virtual machine (`port=80`).
-   Variables RESOURCE_ID and VIRTUAL_MACHINE_UUID should be defined (see Task 8).
-   Nginx default page should be configured to return the same text as we put previously into the storage account in Task 8: "This message was generated on virtual machine ${RESOURCE_ID} with the following UUID ${VIRTUAL_MACHINE_UUID}".
-   Nginx server should be started.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- Azure resources created as expected (check Azure Portal)
- Nginx server responds on User's IP Address with expected response

## TASK 14 - Modules

Learn about [terraform modules](https://www.terraform.io/docs/language/modules/develop/index.html)

Refine your configurations:

- Refine `base` configuration by creating module for Virtual Network related resources: virtual network, subnets.
- Refine `base` configuration by creating module for network security group related resources.
- Refine `base` configuration by creating module for Role related resources.
- [Optional] Refine `compute` configuration by creating a scale set module.


Store your modules in `~/tf-epam-lab/modules/` subfolders.

Run `terraform validate` and `terraform fmt` to check if your modules are valid and fit to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.
