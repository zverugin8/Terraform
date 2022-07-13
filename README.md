- [Introduction](#introduction)
  * [What is IaC and Terraform?](#what-is-infrastructure-as-code-iac-and-terraform)
  * [Core concepts](#core-concepts)
  * [Terraform in 15 minutes](#terraform-in-15-minutes)
  * [Useful links](#useful-links)
  * [Check yourself](#check-yourself)
- [Problem to Be Solved](#problem-to-be-solved)
  * [Explanation of the Solution](#explanation-of-the-solution)
  * [PRE-REQUISITES](#pre-requisites)
- [Creating Infrastructure](#creating-infrastructure)
  * [TASK 1 - Creating VPC](#task-1---creating-vpc)
  * [TASK 2 - Import Your SSH Key into AWS](#task-2---import-your-ssh-key-into-aws)
  * [TASK 3 - Create S3 Bucket](#task-3---create-s3-bucket)
  * [TASK 4 - Create IAM Resources](#task-4---create-iam-resources)
  * [TASK 5 - Create Security Group](#task-5---create-security-group)
  * [TASK 6 - Form TF Output](#task-6---form-tf-output)
  * [TASK 7 - Configure remote data source](#task-7---configure-remote-data-source)
  * [TASK 8 - Create EC2/ASG/ELB](#task-8---create-ec2-asg-elb)
- [Working with Terraform state](#working-with-state)
  * [TASK 9 - Move state to S3/Locking](#task-9---move-state-to-s3-locking)
  * [TASK 10 - Move resources](#task-10---move-resources)
  * [TASK 11 - Import resources](#task-11---import-resources)
  * [TASK 12 - Use data discovery](#task-12---use-data-discovery)
- [Advanced tasks](#advanced-tasks)
  * [TASK 13 - Expose node output with nginx](#task-13---expose-node-output-with-nginx)
  * [TASK 14 - Modules](#task-14---modules)


![ˈtɛrəfɔːm](https://i.imgur.com/RXAzrGo.jpg)

# Introduction
## What is Infrastructure as Code (IaC) and Terraform?

Infrastructure as code is a mainstream practice of working with cloud providers. In a nutshell, it allows engineers to effectively manage their cloud resources using code. Terraform is one of the most popular (and not without reason!) IaC tools available today. It allows to declare the infrastructure using simple and readable code, which the tool itself then uses to provision all described resources in a necessary order.

Terraform was created by Hashicorp, and is meant to *build and change infrastructure safely and efficiently* as declared in its mission statement by Mitchell Hashimoto, one of Hashicorp's founders. The tool supports provisioning resources using a multitude of providers, but it's not limited to clouds like AWS, GCP or Azure; it also supports working with Kubernetes, Vault, Helm, Consul, VMware vSphere and [dozens](https://registry.terraform.io/browse/providers) of other providers.

To sum it up, Terraform is a powerful, flexible and constantly developing IaC tool successfully used by a community of thousands of professionals around the world.

**Why IaC?**

IaC is a very easy sell. Its main advantages are:

- Speed: resources like whole Kubernetes clusters can be created in mere minutes;
- Consistency: version control and code validation ensure smooth deployment;
- Scalability: from single security group rules to giant EKS clusters;
- Costs: IaC efficiency and scalability allow to optimize infrastructure better);
- Security: secure configurations are enforced and can't be changed in the immutable infrastructure paradigm.

**Why Terraform?**

There are many other IaC tools. Why use Terraform specifically? Apart from the aforementioned wide choice of providers (and thus the ability to manage multi-cloud infrastructure using just one tool), it's also open source. Similar tools like **AWS CloudFormation**, **Azure Resource Manager** and **Google Cloud Deploy** only work with their corresponding cloud environments.

Don't confuse Terraform with *configuration management tools* like **Ansible**, **Chef**, **Puppet** or **SaltStack**. These work with traditional **mutable** infrastructure that continually changes (e.g. an admin uses SSH to change something in an already provisioned EC2 instance or a security group) and is susceptible to configuration drift. These tools also often need a master server and agent installation. Terraform is designed to work with **immutable** infrastructure which (generally) doesn't change after provisioning and conveniently doesn't require any of that.

Another important Terraform characteristic is **idempotency**. In this context it basically means that infrastructure, once provisioned, won't be changed by running the same provision command again.

Finally, Terraform uses Hashicorp Configuration Language (HCL), which is designed to be simple to learn and to read. HCL is far more flexible and convenient than JSON, YAML or XML.


![errored.tfstate](https://i.imgur.com/6djFpKQ.jpg)

## Core concepts

**Configuration files**

Terraform configuration files (or simply configuration) is a complete document written in the HCL language that tells Terraform how to manage a given collection of infrastructure. A configuration can consist of multiple files and directories. It is important to remember that it represents the **desired state** of resources and does not represent the actual **provisioned resources**.

**Terraform state**

The most important concept to grasp for beginners. Think of [Terraform state](https://www.terraform.io/language/state) as a special database where the tool stores what it knows about your provisioned resources. State allows Terraform to know when and where to make changes described in configuration files. **Terraform state**, **provisioned resources** and **configuration files** are crucial to understand. Always remember those three separate entities that Terraform works with and why it works with them.

What happens when you use commands like `terraform apply` or `terraform destroy`? The tool reconciles the desired state (configuration files with your code) with actual resources (in AWS in our case) and, if necessary, makes changes, modifying the state so it reflects the actual resources at the moment of successfully running the command.

Terraform state can be stored locally (not recommended if you're not working alone and for security reasons) and in remote storage (e.g. in an S3 bucket which is usually specifically created for it). When Terraform runs, it locks the remote state so it can't be modified by other users while the infrastructure is being provisioned; this prevents state errors that can occur when two or more engineers modify the same resources at the same time.

**Init, plan, apply, destroy and refresh**

The four main terraform commands you'll use often. Let's see what each of them does.

- `terraform init` in a directory with configuration files pulls all the necessary modules to be used later and connects to Terraform state (setting it up locally or remotely);
- `terraform plan` allows to, well, plan your infrastructure changes without applying them;
- `terraform apply` runs `plan` and provisions everything described in the code after prompting for approval;
- `terraform destroy` does the opposite, planning the deletion and then deleting any resources described in the code after prompting for approval;
- `terraform refresh` reads the current settings from all managed resources and updates the Terraform state to match. It **does not** add any new resources (not described in the configuration) to the Terraform state.

**Validate and fmt**

Two simple but very handy commands to make sure your code is valid and looks good. Use them regularly. Or even better - automatically!

- `terraform validate` command validates the consistency and syntax of configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc;
- `terraform fmt` rewrites Terraform configuration files according to [a canonical format and style](https://www.terraform.io/language/syntax/style).


![terraform apply --auto-approve](https://i.imgur.com/LRbRrAB.jpg)

**Providers**

Let's circle back to [providers](https://www.terraform.io/language/providers). These are basically Terraform subcomponents that each handle the interactions with specific platform like AWS or Azure. Providers are developed by Hashicorp itself, Terraform community and third party companies that want their services to be easily available to Terraform users.

If you're working with both AWS and Azure (or Digital Ocean, GCP etc.), you will need to specify said providers and their versions in the code. A provider allows you to address resources specific to them, e.g. the AWS provider works with resources like EC2 instances, IAM policies, security groups and many others, the Kubernetes provider works with namespaces, deployments, ingresses, configmaps and so on.

At the same time, there are basic providers that allow Terraform to work with, say, files, external binaries, security keys or just random numbers. These can all be very useful in defining your infrastructure.

It is important to note that even mature providers like AWS don't have some resources offered by their corresponding native services. Just take at look at its [changelog](https://github.com/hashicorp/terraform-provider-aws/blob/main/CHANGELOG.md). So, while Terraform is indeed powerful, it sometimes can't do everything, as it depends on providers making their resources addressable.


![interconnected](https://i.imgur.com/VGx7ETu.jpg)

**Data sources and outputs**

Terraform [data sources](https://www.terraform.io/language/data-sources) encompass various queries that Terraform can execute to get the necessary information from outside of Terraform itself, another configuration or some function. For example, your application can be provisioned using several Terraform states which need to share some data like VPC or security group ids. If said ids change, running `terraform apply` will provide their new values in real time.

So, how a data source gets some data from another Terraform state? That state needs to have defined [outputs](https://www.terraform.io/language/values/outputs). These can have any useful information like RDS hostnames, CIDRs or security group ids written to them. Outputs are also used in modules.

**Modules**

Terraform [modules](https://www.terraform.io/language/modules) are basically classes. They can make your code reusable in multiple configurations. Need to provision EKS clusters for Application A and Application B? Use [the official module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)! Need more features or specific customizations? Modify it or create your own module from scratch! Although the last option means you are now maintaining your own module, which is a non-trivial task.

A module usually needs you to provide the necessary variables like VPC CIDRs or Kubernetes cluster version. It then uses its own configuration with predefined providers and resources to quickly provision the specified infrastructure piece, while also providing useful outputs.

Modules are, again, [plentiful](https://registry.terraform.io/) and are developed by a massive worldwide community.

**Variables and locals**

Think of Terraform [variables](https://www.terraform.io/language/values/variables) as function arguments. They let you customize aspects of Terraform modules without altering the module's own source code. This allows you to share modules across different Terraform configurations, making your module composable and reusable. The aforementioned outputs are like function return values.

[Locals](https://www.terraform.io/language/values/locals) are simply transformed values used by a module or configuration. You can think of them as temporary local variables of a function needed for it to work properly.

**Functions**

HCL, as most other languages, provides a standard library of [functions](https://www.terraform.io/language/functions) you can use to make mutations to variables and any other data you need to pass around. Need to multiply something or split a string? There are functions for that. Need to decode some JSON data or get an md5 hash? There are functions for that as well. Generate some numbers with set step value? You got it.

**Workspaces**

Each Terraform configuration has an associated backend that defines how operations are executed and where persistent data such as the Terraform state are stored (locally, in an S3 bucket, in Consul and so on).

The persistent data stored in the backend belongs to a [workspace](https://www.terraform.io/language/state/workspaces). Initially the backend has only one workspace, called "default", and thus there is only one Terraform state associated with that configuration. Certain backends support multiple named workspaces, allowing multiple states to be associated with a single configuration. The configuration still has only one backend, but multiple distinct instances of that configuration to be deployed without configuring a new backend or changing authentication credentials.

Creating additional workspaces is optional, but can be useful in certain situations (for example, if you have multiple EKS clusters in different AWS regions).

You can also use an additional tool like [Terraspace](https://github.com/boltops-tools/terraspace) or [Terragrunt](https://github.com/gruntwork-io/terragrunt). These are also completely optional, but can make your workflow easier if you need the features they offer (and you are willing to invest additional time to learn them).


## Terraform in 15 minutes

For a brief but still substantial overall explanation of what Terraform is please refer to this video:

[![Terraform in 15 minutes](https://res.cloudinary.com/marcomontalbano/image/upload/v1642606872/video_to_markdown/images/youtube--l5k1ai_GBDE-c05b58ac6eb4c4700831b2b3070cd403.jpg)](https://www.youtube.com/watch?v=l5k1ai_GBDE "Terraform in 15 minutes")


## Useful links

- [Terraform documentation](https://www.terraform.io/docs). You will use it **a lot**. Most important sections to look at first:

    - [syntax](https://www.terraform.io/language/syntax/configuration)

    - [style conventions](https://www.terraform.io/language/syntax/style)

    - [conditional expressions](https://www.terraform.io/language/expressions/conditionals)


- [Terraform AWS tutorials](https://learn.hashicorp.com/collections/terraform/aws-get-started). Beginner friendly and quick.

- [A longer (2+ hours) Terraform tutorial video](https://www.youtube.com/watch?v=SLB_c_ayRMo). More comprehensive and detailed.

- Terraform best practices links:

    - [A comprehensive compilation of best practices by Anton Babenko and Terraform community](https://www.terraform-best-practices.com/)

    - [A few more best practices and useful hints](https://github.com/ozbillwang/terraform-best-practices)

    - [Workflow recommended practices by Hashicorp](https://www.terraform.io/cloud-docs/guides/recommended-practices)

- [EPAM Terraform Associate Certification Preparation](https://videoportal.epam.com/playlist/VYjK5oJ0/play/V7goNx70) (5 videos). A set of lectures to prepare for the official Terraform certification process.

- [EPAM Terraform Associate Certification Overview](https://kb.epam.com/download/attachments/1109962808/Terraform%20Associate%20Certification%20Preparation%20by%20Armando%20Herra.pptx?version=1&modificationDate=1622464133944&api=v2). Clear and concise presentation you can use as a starting point on the road to getting the Terraform Associate certificate.

## Check yourself

Try to answer these questions using the knowledge you've just gained. Imagine you have provisioned a configuration with an EC2 instance in AWS using `terraform apply`, so you have a) your configuration files, b) local Terraform state with said EC2 instance already in it and c) actual provisioned working resources in AWS.

1. What will happen to a), b) and c) after you delete a resource (an EC2 instance for example) **from its configuration file** and use `terraform apply`?
2. What will happen after you delete the same resource **in AWS** and use `terraform apply`?
3. What will happen after you delete the same resource **in your Terraform state** and use `terraform apply`?
4. What will happen after you change the same resource **in the configuration file** and use `terraform apply`?
5. What will happen after you delete the same resource **from its configuration file** and use `terraform destroy`?

And some additional questions to think about:

1. What's the difference between a provider and a module?
2. What will happen if you delete you Terraform state file?
3. What will happen if you delete a provider from your local `.terraform` directory in your configuration?
4. What will happen if you delete the entire `.terraform` directory in your configuration?

If you're certain you have answered all (or most) of them correctly, great job! You're most definitely ready for the main part of this lab.


# Problem to Be Solved in This Lab
 This lab shows you how to use Terraform to create infrastructure in AWS including auto-scaling group, VPC, subnets, security groups and IAM role. Each instance will report its data to a specified S3 bucket on startup. This task is binding to real production needs – for instance developers could request instances with ability to writing debug information to S3 bucket.

 
### Explanation of the Solution 
You will use Terraform with AWS provider to create 2 separate Terraform configurations:
 1) Base configuration
 2) Compute configuration
After you’ve created configuration, we will work on its optimization like using data driven approach and creating modules.


## PRE-REQUISITES
1. Fork current repository. A fork is a copy of a project and this allows you to make changes without affecting the original project.
2. All actions should be done under your fork and Terraform gets it context from your local clone working directory: 
    - Change current directory to `/tf_aws_lab/base` folder and create `root.tf` file. 
    - Add a `terraform {}`empty block to this file. Create an AWS provider block inside `root.tf` file with the following attributes: 
        - `region = "us-east-1"`
        - `shared_credentials_file = "~/.aws/credentials"`.

**Hint**: Add your AWS credentials to the `~/.aws/credentials` file. Refer to [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) document for details.

Run `terraform init` to initialize your configuration. 
Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to ensure that there are no changes.

Please use **underscore** Terraform resources naming, e.g. `my_resource` instead of `my-resource`.

3. Change current directory  to `~/tf_aws_lab/compute` and repeat the steps in [2].

You are ready for the lab!

# Creating Infrastructure

## TASK 1 - Creating VPC
Change current directory  to `~/tf_aws_lab/base`

Create a network stack for your infrastructure:

-	**VPC**: `name={StudentName}-{StudentSurname}-01-vpc`, `cidr=10.10.0.0/16`
-	**Public subnets**:
    - `name={StudentName}-{StudentSurname}-01-subnet-public-a`, `cidr=10.10.1.0/24`, `az=a`)
    - `name={StudentName}-{StudentSurname}-01-subnet-public-b`, `cidr=10.10.3.0/24`, `az=b`)
    - `name={StudentName}-{StudentSurname}-01-subnet-public-c`, `cidr=10.10.5.0/24`, `az=c`)
-	**Internet gateway**: `{StudentName}-{StudentSurname}-01-igw`
-	**Routing table to bind IGW with Public subnets**: `name={StudentName}-{StudentSurname}-01-rt`

**Hint**: A local value assigns a name to an expression, so you can use it multiple times within a module without repeating it. 

Store all resources from this task in the `vpc.tf` file.
Store all locals in `locals.tf`.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
    - `Owner={StudentName}_{StudentSurname}`

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 2 - Import Your SSH Key into AWS

Ensure that the current directory is `~/tf_aws_lab/base`

Create a custom ssh key-pair to access your ec2 instances:

- Create your ssh key pair [refer to this document](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws)
- Create a `variables.tf` file with empty variable "ssh_key" but with the following description "Provides custom public ssh key". Never store you secrets inside the code!
- Create a `key_pair.tf` file with `aws_key_pair` resource. Use ssh_key variable as a public key source.
- Run `terraform plan` and provide required public key. Observe the output and run `terraform plan` again.
- To prevent providing ssh key on each configuration run and staying secure set binding environment variable - `export TF_VAR_ssh_key="YOUR_PUBLIC_SSH_KEY_STRING"`
- Run `terraform plan` and observe the output.


Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
    - `Owner={StudentName}_{StudentSurname}`


Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.

Apply your changes when ready.

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.

## TASK 3 - Create an S3 Bucket

Ensure that the current directory is  `~/tf_aws_lab/base`

Create an S3 bucket as the storage for your infrastructure:

-	Create `s3.tf`. Name your bucket "epam-aws-tf-lab-${random_string.my_numbers.result}" to provide it with partition unique name. See [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) documentation for details.
-	Set bucket acl as private. Never share your bucket to the whole world!

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
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
Ensure that the current directory is  `~/tf_aws_lab/base`

Create IAM resources:

-	**IAM group** (`name=test-move`).
-	**IAM policy** with write permission for "epam-aws-tf-lab" bucket only (`name=s3-write-epam-aws-tf-lab-${random_string.my_numbers.result}`). Hint: store your policy as json document side by side with configurations (or create 'files' subfolder for storing policy) and use templatefile() function to transfer IAM policy with imported S3 bucket name to a resource.
-	Create **IAM role**, attach the policy to it and create **IAM instance profile** for this IAM role. Allow to assume this role for ec2 service.

Store all resources from this task in the `iam.tf` file.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
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
Ensure that the current directory is  `~/tf_aws_lab/base`

Create the following resources:

-	Security group (`name=ssh-inbound`, `port=22`, `allowed_ip_range="your_IP or EPAM_office-IP_range"`, `description="allows ssh access from safe IP-range"`).
-	Security group (`name=lb-http-inbound`, `port=80`, `allowed_ip_range="your_IP or EPAM_office-IP_range"`, `description="allows http access from safe IP-range to a LoadBalancer"`).
-	Security group (`name=http-inbound`, `port=80`, `source_security_group_id=id_of_lb-http-inbound_sg`, `description="allows http access from LoadBalancer"`). 
-   Make the most of the `aws_security_group_rule` resource. 

**Hint:** source_security_group_id is an attribute of[aws_security_group_rule resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule). For details about how to configure securitygroups for loadbalancer see [documentation] (https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-groups.html)


Store all resources from this task in the `sg.tf` file.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
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
Ensure that current directory is  `~/tf_aws_lab/base`

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

! Change the current directory to  `~/tf_aws_lab/compute`
! Copy `root.tf` from `~/tf_aws_lab/base` to `~/tf_aws_lab/compute`

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

Ensure that the current directory is  `~/tf_aws_lab/compute`

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
- Create a Classic Loadbalancer and attach it to an auto-scaling group with `aws_autoscaling_attachment`. Configure `aws_autoscaling_group` to ignore changes to the `load_balancers` and `target_group_arns` arguments within a lifecycle configuration block (lb_port=80, instance_port=80, protocol=http, `security_group_id={lb-http-inbound-id}`).

Store all resources from this task in the `asg.tf` file.

Equip all resources with following tags:
    - `Terraform=true`, 
    - `Project=epam-tf-aws-lab`
    - `Owner={StudentName}_{StudentSurname}`

Please keep in mind that autoscaling group requires using a special format for `Tags` section!


Run `terraform validate` and `terraform fmt` to check if your configuration valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes.

Apply your changes when you're ready.

As a result ec2 instance should be launched by autoscaling-group and a new file should be created in your S3 bucket. 

### Definition of DONE:

- Terraform created infrastructure with no errors
- AWS resources created as expected (check AWS Console)
- Push *.tf configuration files to git
- Check your efforts through the proctor gitlab pipeline.
    
# Working with Terraform state

**Mandatory**: Please do not proceed to TASKs 9-14 until your have finished previous tasks. Once completed please remove .gitlab-ci.yml from your repository. 

## TASK 9 - Move state to S3/Locking

Hint: Create an S3 Bucket(`name=epam-aws-tf-state`) and a DynamoDB table as a pre-requirement for this task. There are multiple ways to do this, including Terraform and CloudFormation. But
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

- Move the `test-move` IAM group from the `base` state to the `compute` using `terraform state mv` command.
- Update both configurations according to this move.
- Run `terraform plan` on both configurations and observe the changes. Hint: there should not be any changes detected (no resource creation or deletion in case of correct resource move).

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.

### Definition of DONE:

- Terraform moved resources with no errors
- AWS resources are NOT changed (check AWS Console)
- Save following artifacts under `/reports/task10/` folder:
    - `terraform.tfstate` file for both configurations

## TASK 11 - Import resources

Learn about the [terraform import](https://www.terraform.io/docs/cli/import/index.html) command.

You are going to import a new resource (IAM group) to your state.
Hint: Keep in mind that there are 3 instances: AWS resource, Terraform state file which store some state of that resource, and Terraform configuration which describe resource. "Importing a resource" is importing its attributes into a Terraform state. Then you have to add said resource to the destination configuration (this action is not automated).

- Create an IAM group in AWS Console(name="test-import").
- Add a new resource aws_iam_group "test-import" to the `compute` configuration.
- Run `terraform plan` to see your changes but do not apply changes.
- Import `test-import` IAM group to the `compute` state.
- Run `terraform plan` again to ensure that import was successful.

Run `terraform validate` and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style.
If applicable all resources should be tagged with following tags {Terraform=true, Project=epam-tf-aws-lab}.
If applicable all resources should be defined with the provider alias.


- Terraform imported resources with no errors
- AWS resources are NOT changed (check AWS Console)
- Save following artifacts under `/reports/task11/` folder:
    - `terraform.tfstate` file for `compute` configuration

## TASK 12 - Use data discovery
Learn about [terraform data sources](https://www.terraform.io/docs/language/data-sources/index.html) and [querying terraform data sources](https://learn.hashicorp.com/tutorials/terraform/data-sources?in=terraform/configuration-language&utm_source=WEBSITE&utm_medium=WEB_BLOG&utm_offer=ARTICLE_PAGE).

In this task we are going to use a data driven approach instead to use remote state data source.

#### base configuration
Change current directory to `~/tf_aws_lab/base`
Refine your configuration :

- Use a data source to request Availability zones for us-east-1 region and assign your vpc with appropriate AZs. Hint: select such AZ numbers that will not initiate resource recreation and were already assigned to your VPC.

Store all resources from this task in the `data.tf` file.

Run `terraform validate`  and `terraform fmt` to check if your configuration is valid and fits to a canonical format and style. Do this each time before applying your changes.
Run `terraform plan` to see your changes. You can also use `terraform refresh`.
If applicable all resources should be defined with the provider alias.

Apply your changes when ready.

#### compute configuration
Change the current directory to `~/tf_aws_lab/compute`

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

Ensure that the current directory is  `~/tf_aws_lab/compute`

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
- Nginx server responds on Loadbalancer's IP Address with expected response 
- Save the following artifacts under `/reports/task13/` folder:
    - `terraform.tfstate` file
    - `terraform apply` log (`tf_apply.log`)
    - `terraform plan` (after changes) log (`tf_plan_after.log`)

## TASK 14 - Modules

Learn about [terraform modules](https://www.terraform.io/docs/language/modules/develop/index.html)

Refine your configurations:

- Refine `base` configuration by creating module for VPC related resources: vpc, subnets, routes, internet gateways.
- Refine `base` configuration by creating module for security group related resources.
- Refine `base` configuration by creating module for IAM role related resources.
- [Optional] Refine `compute` configuration by creating Autoscaling group module.


Store your modules in `~/tf_aws_lab/modules/` subfolders.

Run `terraform validate` and `terraform fmt` to check if your modules are valid and fit to a canonical format and style.
Run `terraform plan` to see your changes and re-apply your changes if needed.
