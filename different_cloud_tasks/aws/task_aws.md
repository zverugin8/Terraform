- [Problem to Be Solved](task_aws.md#problem-to-be-solved)
  * [Explanation of the Solution](task_aws.md#explanation-of-the-solution)
  * [PRE-REQUISITES](task_aws.md#pre-requisites)
- [Creating Infrastructure](task_aws.md#creating-infrastructure)
  * [TASK 1 - Creating VPC](task_aws.md#task-1-creating-vpc)
  * [TASK 2 - Import Your SSH Key into AWS](task_aws.md#task-2-import-your-ssh-key-into-aws)
  * [TASK 3 - Create an S3 Bucket](task_aws.md#task-3-create-an-s3-bucket)
  * [TASK 4 - Create IAM Resources](task_aws.md#task-4-create-iam-resources)
  * [TASK 5 - Create a Security Group](task_aws.md#task-5-create-a-security-group)
  * [TASK 6 - Form TF Output](task_aws.md#task-6-form-tf-output)
  * [TASK 7 - Configure a remote data source](task_aws.md#task-7-configure-a-remote-data-source)
  * [TASK 8 - Create EC2/ASG/ELB](task_aws.md#task-8-create-ec2asgelb)
- [Working with Terraform state](task_aws.md#working-with-terraform-state)
  * [TASK 9 - Move state to S3/Locking](task_aws.md#task-9-move-state-to-s3locking)
  * [TASK 10 - Move resources](task_aws.md#task-10-move-resources)
  * [TASK 11 - Import resources](task_aws.md#task-11-import-resources)
  * [TASK 12 - Use data discovery](task_aws.md#task-12-use-data-discovery)
- [Advanced tasks](task_aws.md#advanced-tasks)
  * [TASK 13 - Expose node output with nginx](task_aws.md#task-13-expose-node-output-with-nginx)
  * [TASK 14 - Modules](task_aws.md#task-14-modules)
  


# Problem to Be Solved in This Lab
This lab shows you how to use Terraform to create infrastructure in AWS including an auto-scaling group, a VPC, subnets, security groups, and an IAM role. Each instance will report its data to a specified S3 bucket on startup. This task is binding to real production needs – for instance, developers could request instances with the ability to write debug information to an S3 bucket.

 
### Explanation of the Solution 
You will use Terraform with the AWS provider to create 2 separate Terraform configurations:
 1) Base configuration
 2) Compute configuration
After you’ve created the configuration, we will work on its optimization like using a data-driven approach and creating modules.


## PRE-REQUISITES
1. Fork current repository. A fork is a copy of a project and this allows you to make changes without affecting the original project.
2. All actions should be done under your fork and Terraform gets it context from your local clone working directory: 
    - Change current directory to `/tf-epam-lab/base` folder and create `root.tf` file. 
    - Add a `terraform {}`empty block to this file. Create an AWS provider block inside `root.tf` file with the following attributes: 
        - `region = "us-east-1"`
        - `shared_credentials_file = "~/.aws/credentials"`.

**Hint**: Add your AWS credentials to the `~/.aws/credentials` file. Refer to [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) document for details.

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

-	**VPC**: `name={StudentName}-{StudentSurname}-01-vpc`, `cidr=10.10.0.0/16`
-	**Public subnets**:
    - `name={StudentName}-{StudentSurname}-01-subnet-public-a`, `cidr=10.10.1.0/24`, `az=a`)
    - `name={StudentName}-{StudentSurname}-01-subnet-public-b`, `cidr=10.10.3.0/24`, `az=b`)
    - `name={StudentName}-{StudentSurname}-01-subnet-public-c`, `cidr=10.10.5.0/24`, `az=c`)
-	**Internet gateway**: `{StudentName}-{StudentSurname}-01-igw`
-	**Routing table to bind IGW with Public subnets**: `name={StudentName}-{StudentSurname}-01-rt`

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
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 2 - Create an S3 Bucket

Ensure that the current directory is  `~/tf-epam-lab/base`

Create an S3 bucket as the storage for your infrastructure:

-	Create `storage.tf`. Name your bucket "epam-aws-tf-lab-${random_string.my_numbers.result}" to provide it with partition unique name. See [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) documentation for details.
-	Set bucket acl as private. Never share your bucket to the whole world!

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 4 - Create IAM Resources
Ensure that the current directory is  `~/tf-epam-lab/base`

Create IAM resources:

-	**IAM group** (`name=test-move`).
-	**IAM policy** with write permission for "epam-aws-tf-lab" bucket only (`name=s3-write-epam-aws-tf-lab-${random_string.my_numbers.result}`). Hint: store your policy as json document side by side with configurations (or create 'files' subfolder for storing policy) and use templatefile() function to transfer IAM policy with imported S3 bucket name to a resource.
-	Create **IAM role**, attach the policy to it and create **IAM instance profile** for this IAM role. Allow to assume this role for ec2 service.

Store all resources from this task in the `iam.tf` file.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 5 - Create a Security Group
Ensure that the current directory is  `~/tf-epam-lab/base`

Create the following resources:

-	Security group (`name=ssh-inbound`, `port=22`, `allowed_ip_range="your_IP or EPAM_office-IP_range"`, `description="allows ssh access from safe IP-range"`).
-	Security group (`name=lb-http-inbound`, `port=80`, `allowed_ip_range="your_IP or EPAM_office-IP_range"`, `description="allows http access from safe IP-range to a LoadBalancer"`).
-	Security group (`name=http-inbound`, `port=80`, `source_security_group_id=id_of_lb-http-inbound_sg`, `description="allows http access from LoadBalancer"`). 
-   Make the most of the `aws_security_group_rule` resource. 

**Hint:** source_security_group_id is an attribute of[aws_security_group_rule resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule). For details about how to configure securitygroups for loadbalancer see [documentation] (https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html)


Store all resources from this task in the `network_security.tf` file.

Equip all resources with following tags:
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
- Check your efforts through the proctor gitlab pipeline.

## TASK 6 - Form TF Output
Ensure that current directory is  `~/tf-epam-lab/base`

Create outputs for your configuration:

- Create `outputs.tf` file.
- Following outputs are required: `vpc_id`, `public_subnet_ids`[set of strings], `security_group_id_ssh`, `security_group_id_http`, `security_group_id_http_lb`, `iam_instance_profile_name`, `key_name`, `s3_bucket_name`.

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

## TASK 8 - Create EC2/ASG/ELB

Ensure that the current directory is  `~/tf-epam-lab/compute`

Create auto-scaling group resources:

- Create a Launch Template resource. (`name=epam-aws-tf-lab`,`image_id="actual Amazon Linux AMI2 image id"`, `instance_type=t2.micro`,`security_group_id={ssh-inbound-id,http-inbound-id}`,`key_name`,`iam_instance_profile`, `user_data script`)
- Provide a template with `delete_on_termination = true` network interface parameter - to automate clean-up of the resources
- Author a User Data bash script which should get 2 parameters on instance start-up and send it to a S3 Bucket as a text file with instance_id as its name:

User Data Details:

Getting EC2 Metadata
```
EC2_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid |tr '[:upper:]' '[:lower:]')
INSTANCE_ID=$(replace this text with request instance id from metadata e.g. using curl)
```

command to send text to S3 bucket (**use data rendering to pass the Bucket Name to this script**):
```
This message was generated on instance {INSTANCE_ID} with the following UUID {EC2_MACHINE_UUID}
echo "This message was generated on instance ${INSTANCE_ID} with the following UUID ${EC2_MACHINE_UUID}" | aws s3 cp - s3://{Backet name from task 3}/${INSTANCE_ID}.txt
```

- Create an `aws_autoscaling_group` resource. (`name=epam-aws-tf-lab`,`max_size=min_size=1`,`launch_template=epam-aws-tf-lab`)
- Create a Application Loadbalancer and attach it to an auto-scaling group with `aws_autoscaling_attachment`. Configure `aws_autoscaling_group` to ignore changes to the `load_balancers` and `target_group_arns` arguments within a lifecycle configuration block (lb_port=80, instance_port=80, protocol=http, `security_group_id={lb-http-inbound-id}`).

Store all resources from this task in the `application.tf` file.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-lab`
    - `Owner={StudentName}_{StudentSurname}`

Please keep in mind that autoscaling group requires using a special format for `Tags` section!


Run `terraform validate` and `terraform fmt` to check if your configuration valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

As a result ec2 instance should be launched by autoscaling-group and a new file should be created in your S3 bucket. 

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- After a new instance launch, a new text file appears in the S3 bucket with the appropriate text.
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.
    
# Working with Terraform state

**Mandatory**: Please do not proceed to TASKs 9-14 until your have finished previous tasks. Once completed please remove .gitlab-ci.yml from your repository. 

## TASK 9 - Move state to S3/Locking

Hint: Create an S3 Bucket(`name=epam-aws-tf-state-${random_string}`) and a DynamoDB table as a pre-requirement for this task. There are multiple ways to do this, including Terraform and CloudFormation. But
please just create both resources by a hands in AWS console. Those resources will be out of our IaC approach as they will never be recreated.

Learn about [terraform backend in AWS S3](https://www.terraform.io/docs/language/settings/backends/s3.html)

Refine your configurations:

- Refine `base` configuration by moving local state to a s3.
- Refine `base` configuration by adding locking with DynamoDB.
- Refine `compute` configuration by moving local state to a s3.
- Refine `compute` configuration by adding locking with DynamoDB.

Do not forget to change the path to the remote state for `compute` configuration.

Run `terraform validate` and `terraform fmt` to check if your modules valid and fits to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.

## TASK 10 - Move resources

Learn about [terraform state mv](https://www.terraform.io/docs/cli/commands/state/mv.html) command

You are going to move previously created resource(IAM group) from `base` to `compute` state.
Hint: Keep in mind that there are 3 instances: AWS resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Move resource" is moving it between states. Moreover to make it work you should delete said resource from source configuration and add it to the destination configuration (this action is not automated).

- Move The created AWS key pair resource from the `base` state to the `compute` using `terraform state mv` command.
- Update both configurations according to this move.
- Run `terraform plan` on both configurations and observe the changes. Hint: there should not be any changes detected (no resource creation or deletion in case of correct resource move).

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.

### Definition of DONE:

- Terraform moved resources with no errors
- AWS resources are NOT changed (check AWS Console)

## TASK 11 - Import resources

Learn about the [terraform import](https://www.terraform.io/docs/cli/import/index.html) command.

You are going to import a new resource (IAM group) to your state.
Hint: Keep in mind that there are 3 instances: AWS resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Importing a resource" is importing its attributes into a Terraform state. Then you have to add said resource to the destination configuration (this action is not automated).

- Create an IAM Role in AWS Console (`name="test-import"`).
- Add a new resource aws_iam_role `test-import` to the `compute` configuration.
- Run `terraform plan` to see your changes but do not apply changes.
- Import `test-import` IAM role to the `compute` state.
- Run `terraform plan` again to ensure that import was successful.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.
If applicable all resources should be tagged with following tags:
- `Terraform=true`,
- `Project=epam-tf-lab`.
If applicable all resources should be defined with the provider alias.

- Terraform imported resources with no errors
- AWS resources are NOT changed (check AWS Console)

## TASK 12 - Use data discovery
Learn about [terraform data sources](https://www.terraform.io/docs/language/data-sources/index.html) and [querying terraform data sources](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_BLOG&utm_offer=ARTICLE_PAGE).

In this task we are going to use a data driven approach instead to use remote state data source.

#### base configuration
Change current directory to `~/tf-epam-lab/base`

Refine your configuration :
- Use a data source to request a project numeric ID and , 
- Use a data source to request a region for the provider.

Store all resources from this task in the `data.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes. You can also use `terraform refresh`.
If applicable all resources should be defined with the provider alias.

Apply your changes when ready.

#### compute configuration
Change the current directory to `~/tf-epam-lab/compute`

Refine your configuration:

- Use a data source to request the following resources: `vpc_id`, `public subnet id`, `security group id`, `iam instance profile name`.

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

Change User Data script in the Launch Template as follows:

-   Nginx binary should be installed on instance (`port=80`).
-   Variables INSTANCE_ID and EC2_MACHINE_UUID should be defined (see Task 8).
-   Nginx default page should be configured to return the same text as we put previously into S3 bucket in Task 8: "This message was generated on instance ${INSTANCE_ID} with the following UUID ${EC2_MACHINE_UUID}".
-   Nginx server should be started.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Nginx server responds on Loadbalancer's URL with expected response 

## TASK 14 - Modules

Learn about [terraform modules](https://www.terraform.io/docs/language/modules/develop/index.html)

Refine your configurations:

- Refine `base` configuration by creating module for VPC related resources: vpc, subnets, routes, internet gateways.
- Refine `base` configuration by creating module for security group related resources.
- Refine `base` configuration by creating module for IAM role related resources.
- [Optional] Refine `compute` configuration by creating Autoscaling group module.


Store your modules in `~/tf-epam-lab/modules/` subfolders.

Run `terraform validate` and `terraform fmt` to check if your modules are valid and fit to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.
