- [Problem to Be Solved](task_gcp.md#problem-to-be-solved)
  * [Explanation of the Solution](task_gcp.md#explanation-of-the-solution)
  * [PRE-REQUISITES](task_gcp.md#pre-requisites)
- [Creating Infrastructure](task_gcp.md#creating-infrastructure)
  * [TASK 1 - Creating VPC](task_gcp.md#task-1-creating-vpc)
  * [TASK 2 - Create a project metadata](task_gcp.md#task-2-create-a-project-metadata)
  * [TASK 3 - Create a Cloud Storage Bucket](task_gcp.md#task-3-create-a-cloud-storage-bucket)
  * [TASK 4 - Create IAM Resources](task_gcp.md#task-4-create-iam-resources)
  * [TASK 5 - Create Firewall rules](task_gcp.md#task-5-create-firewall-rules)
  * [TASK 6 - Form TF Output](task_gcp.md#task-6-form-tf-output)
  * [TASK 7 - Configure a remote data source](task_gcp.md#task-7-configure-a-remote-data-source)
  * [TASK 8 - Create VM Instance/Instance Group/Load Balancer](task_gcp.md#task-8-create-vm-instanceinstance-groupload-balancer)
- [Working with Terraform state](task_gcp.md#working-with-terraform-state)
  * [TASK 9 - Move state to Cloud Storage Bucket](task_gcp.md#task-9-move-state-to-cloud-storage-bucket)
  * [TASK 10 - Move resources](task_gcp.md#task-10-move-resources)
  * [TASK 11 - Import resources](task_gcp.md#task-11-import-resources)
  * [TASK 12 - Use data discovery](task_gcp.md#task-12-use-data-discovery)
- [Advanced tasks](task_gcp.md#advanced-tasks)
  * [TASK 13 - Expose node output with nginx](task_gcp.md#task-13-expose-node-output-with-nginx)
  * [TASK 14 - Modules](task_gcp.md#task-14-modules)
  


# Problem to Be Solved in This Lab
This lab shows you how to use Terraform to create infrastructure in GCP including an instance group, VPC, subnetworks, firewall rules with network tags, and service accounts. Each instance will report its data to a specified Cloud Storage bucket on startup. This task is binding to real production needs – for instance, developers could request instances with the ability to write debug information to a Cloud Storage bucket.

 
### Explanation of the Solution 
You will use Terraform with the GCP provider to create 2 separate Terraform configurations:
 1) Base configuration
 2) Compute configuration
After you’ve created the configuration, we will work on its optimization like using a data-driven approach and creating modules.


## PRE-REQUISITES
1. Fork current repository. A fork is a copy of a project and this allows you to make changes without affecting the original project.
2. All actions should be done under your fork and Terraform gets it context from your local clone working directory: 
    - Prepare GCP environment: create a GCP project, create a service account, grant `Project Owner` permissions and generate credentials in the JSON format.
    - Change current directory to `/tf-epam-lab/base` folder and create `root.tf` file. 
    - Add a `terraform {}`empty block to this file. Create a GCP provider block inside `root.tf` file with the following attributes: 
        - `project = jsondecode(file("~/.gcp/credentials.json"))["project_id"]`
        - `credentials = file("~/.gcp/credentials.json")`.

**Hint**: Add your GCP credentials to the `~/.gcp/credentials.json` file. Refer to [this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started) document for details.

Run `terraform init` to initialize your configuration. 
Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to ensure that there are no changes.

Please use **underscore** Terraform resources naming, e.g. `my_resource` instead of `my-resource`.

3. Change current directory  to `~/tf-epam-lab/compute` and repeat the steps in [2].

You are ready for the lab!

# Creating Infrastructure

## TASK 1 - Creating VPC
Change current directory  to `~/tf-epam-lab/base`

Create a network stack for your infrastructure:

-	**VPC**: `name={StudentName}-{StudentSurname}-01-vpc`, `auto_create_subnetworks=false`
-	**Public subnetworks**:
    - `name={StudentName}-{StudentSurname}-01-subnetwork-central`, `cidr=10.10.1.0/24`, `region=us-central1`)
    - `name={StudentName}-{StudentSurname}-01-subnetwork-east`, `cidr=10.10.3.0/24`, `region=us-east1`)

**Hint**: A local value assigns a name to an expression, so you can use it multiple times within a module without repeating it. 

Store all resources from this task in the `network.tf` file.
Store all locals in `locals.tf`.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- Push *.tf configuration files to git

## TASK 2 - Create a project metadata

Ensure that the current directory is `~/tf-epam-lab/base`

Create a project metadata:

- Create a project metadata refer to [this document](https://cloud.google.com/compute/docs/metadata/overview) and [this document](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata).
- Create a `variables.tf` file with empty variable `ssh_key` but with the following description "Provides custom public ssh key". Never store you secrets inside the code!
- Create a `ssh.tf` file with `google_compute_project_metadata` resource. Create a metadata item key `shared_ssh_key`, as a value use an `ssh_key` variable as a public key source.
- Run `terraform plan` and provide required public key. Observe the output and run `terraform plan` again.
- To prevent providing ssh key on each configuration run and staying secure set binding environment variable - `export TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"`
- Run `terraform plan` and observe the output.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- Push *.tf configuration files to git

## TASK 3 - Create a Cloud Storage Bucket

Ensure that the current directory is  `~/tf-epam-lab/base`

Create a Cloud Storage bucket as the storage for your infrastructure:

-	Create `storage.tf`. Name your bucket "epam-gcp-tf-lab-${random_string.my_numbers.result}" to provide it with partition unique name. See [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) documentation for details.
-	Set bucket acl as private. Never share your bucket to the whole world!

Equip the bucket with following labels:
    - `Terraform=true`, 
    - `epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- Push *.tf configuration files to git

## TASK 4 - Create IAM Resources
Ensure that the current directory is  `~/tf-epam-lab/base`

Create IAM resources:

-	Create **Service account**, attach the `Project Owner` permission to it.

Store all resources from this task in the `iam.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- Push *.tf configuration files to git

## TASK 5 - Create Firewall rules
Ensure that the current directory is  `~/tf-epam-lab/base`

Create the following resources:

-	Firewall rule (`name=ssh-inbound`, `port=22`, `allowed_ip_ranges="your_IP or EPAM_office-IP_ranges"`, `description="allows ssh access from safe IP-range"`, `target_tags=web-instances`).
-	Firewall rule (`name=http-inbound`, `port=80`, `allowed_ip_ranges="130.211.0.0/22", "35.191.0.0/16"`, `description="allows http access from LoadBalancer"`, `target_tags=web-instances`). 

**Hint:** These firewall should be created for the VPC which was created in the Task 1
**Note:** "130.211.0.0/22", "35.191.0.0/16" are IP ranges of the GCP health checkers. See [there](https://cloud.google.com/load-balancing/docs/firewall-rules)

Store all resources from this task in the `network_security.tf` file.

Equip all resources with following labels:
- `Terraform=true`, 
- `Project=epam-tf-lab`
- `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying  your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git

## TASK 6 - Form TF Output
Ensure that current directory is  `~/tf-epam-lab/base`

Create outputs for your configuration:

- Create `outputs.tf` file.
- Following outputs are required: `vpc_id`, `subnetworks_ids`[set of strings], `service_account_email`, `project_metadata_id`, `bucket_id`.

Store all resources from this task in the `outputs.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready. You can update outputs without using `terraform apply` - just use the `terraform refresh` command.

### Definition of DONE:

- Push *.tf configuration files to git

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

## TASK 8 - Create VM Instance/Instance Group/Load Balancer

Ensure that the current directory is  `~/tf-epam-lab/compute`

Create instance groups resources for subnetworks' regions:

- Create a Instance Template resources for subnetworks' regions:   
  - `name=epam-gcp-tf-lab-{region}`,
  - `source_image="debian-cloud/debian-10"`,
  - `machine_type=f1-micro`,
  - `tags="web-instances"`,
  - `key_name`,
  - `service_account`,
  - `startup-script`
- Author a Startup bash script which should get 2 parameters on instance start-up and send it to a Cloud Storage Bucket as a text file with instance_id as its name:

User Data Details:

Getting VM Metadata
```
VM_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
INSTANCE_ID=$(replace this text with request instance id from metadata e.g. using curl)
```
command to send text to S3 bucket (**use data rendering to pass the Bucket Name to this script**):
```
This message was generated on instance {INSTANCE_ID} with the following UUID {VM_MACHINE_UUID}
echo "This message was generated on instance ${INSTANCE_ID} with the following UUID ${VM_MACHINE_UUID}" | aws s3 cp - s3://{Backet name from task 3}/${INSTANCE_ID}.txt
```
**Note:** Without assigned service account requests to metadata service won't work


- Create an `google_compute_region_instance_group_manager` resource:
  - `name=epam-gcp-tf-lab-{region}`,
  - `target_size=1`,
  - `instance_template=epam-gcp-tf-lab-{region}`
- Create a Global HTTP Loadbalancer and attach it to an instance group with `google_compute_health_check`.

Store all resources from this task in the `application.tf` file.

Ensure that all instances in the instance groups contain:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Please keep in mind that instance groups or an instance templates require using a special format for `labels` section!

Run `terraform validate` and `terraform fmt` to check if your configuration valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

As a result vm instance should be launched by the instance groups and a new file should be created in the Cloud Storage bucket. 

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- After a new instance launch, a new text file appears in the cloud storage bucket storage with the appropriate text.
- Push *.tf configuration files to git

# Working with Terraform state

**Mandatory**: Please do not proceed to TASKs 9-14 until your have finished previous tasks. 

## TASK 9 - Move state to Cloud Storage Bucket

Hint: Create a Cloud Storage Bucket(`name=epam-gcp-tf-state-${random_string}`) as a pre-requirement for this task. Please create the resource by a hands in GCP console. That resource will be out of our IaC approach as it will never be recreated.

Learn about [terraform backend in Cloud Storage Bucket](https://developer.hashicorp.com/terraform/language/settings/backends/gcs)

**Note:** GCS backend supports the state file lock without extra resources unlike AWS S3 bucket.

Refine your configurations:

- Refine `base` configuration by moving local state to a cloud storage bucket.
- Refine `compute` configuration by moving local state to a cloud storage bucket.

Do not forget to change the path to the remote state for `compute` configuration.

Run `terraform validate` and `terraform fmt` to check if your modules valid and fits to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.

## TASK 10 - Move resources

Learn about [terraform state mv](https://www.terraform.io/docs/cli/commands/state/mv.html) command

You are going to move previously created resource (Cloud Storage Bucket) from `base` to `compute` state.
Hint: Keep in mind that there are 3 instances: GCP resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Move resource" is moving it between states. Moreover to make it work you should delete said resource from source configuration and add it to the destination configuration (this action is not automated).

- Move the created project metadata resource from the `base` state to the `compute` using `terraform state mv` command.
- Update both configurations according to this move.
- Run `terraform plan` on both configurations and observe the changes. Hint: there should not be any changes detected (no resource creation or deletion in case of correct resource move).

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.

### Definition of DONE:

- Terraform moved resources with no errors
- GCP resources are NOT changed (check GCP Console)

## TASK 11 - Import resources

Learn about the [terraform import](https://www.terraform.io/docs/cli/import/index.html) command.

You are going to import a new resource (Cloud Storage Bucket) to your state.
Hint: Keep in mind that there are 3 instances: GCP resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Importing a resource" is importing its attributes into a Terraform state. Then you have to add said resource to the destination configuration (this action is not automated).

- Create a IAM Service account in GCP Console (`name="test-import"`).
- Add a new resource `google_service_account` `test_import` to the `compute` configuration.
- Run `terraform plan` to see your changes but do not apply changes.
- Import `test_import` IAM Service account to the `compute` state.
- Run `terraform plan` again to ensure that import was successful.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.
If applicable all resources should be labeled with following labels: 
- `Terraform=true`, 
- `Project=epam-tf-lab`.
If applicable all resources should be defined with the provider alias.

- Terraform imported resources with no errors
- GCP resources are NOT changed (check GCP Console)

## TASK 12 - Use data discovery
Learn about [terraform data sources](https://www.terraform.io/docs/language/data-sources/index.html) and [querying terraform data sources](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_BLOG&utm_offer=ARTICLE_PAGE).

In this task we are going to use a data driven approach instead to use remote state data source.

#### base configuration
Change current directory to `~/tf-epam-lab/base`

Refine your configuration :
- Use a data source to request an account ID,
- Use a data source to request a region operate under.

Hint: These data sources should replace remote state outputs, therefore you can delete `data "terraform_remote_state" "base"` resource from your current state and the `outputs.tf` file from the `base` configuration. **Don't forget to replace references with a new data sources.**
Hint: run `terraform refresh` command under `base` configuration to reflect changes.

Store all resources from this task in the `data.tf` file.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes. Also you can use `terraform refresh`.
If applicable all resources should be defined with the provider alias.

Apply your changes when ready.


# Advanced tasks

## TASK 13 - Expose node output with nginx

Ensure that the current directory is  `~/tf-epam-lab/compute`

Change User Data script in the Instance Template as follows:

-   Nginx binary should be installed on instance (`port=80`).
-   Variables INSTANCE_ID and VM_MACHINE_UUID should be defined (see Task 8).
-   Nginx default page should be configured to return the same text as we put previously into a Cloud Storage bucket in Task 8: "This message was generated on instance ${INSTANCE_ID} with the following UUID ${VM_MACHINE_UUID}".
-   Nginx server should be started.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- GCP resources created as expected (check GCP Console)
- Nginx server responds on Loadbalancer's IP Address with expected response 

## TASK 14 - Modules

Learn about [terraform modules](https://www.terraform.io/docs/language/modules/develop/index.html)

Refine your configurations:

- Refine `base` configuration by creating module for VPC related resources: vpc, subnetworks.
- Refine `base` configuration by creating module for firewall rules.
- Refine `base` configuration by creating module for a service account related resources.
- [Optional] Refine `compute` configuration by creating instance groups module.


Store your modules in `~/tf-epam-lab/modules/` subfolders.

Run `terraform validate` and `terraform fmt` to check if your modules are valid and fit to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.
