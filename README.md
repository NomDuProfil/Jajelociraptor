# JAJELOCIRAPTOR

## Description

This project enables the deployment of the Velociraptor solution (https://docs.velociraptor.app/) on an EC2 server in AWS using Terraform.

With this simple solution, you can quickly obtain an EC2 server with a basic configuration, which will be sent to you via email. In this email, you will find:

- Your login credentials
- The login URL
- A download link for client files (valid for 1 hour)

## Declaration and Deployment

⚠️ Before you begin, check your `provider.tf` file to ensure that you can store your `tfstate` correctly.

⚠️ **During the installation, an email from Amazon will be sent to confirm the legitimacy of your email address. Until this is validated, the installation will be blocked.**

In the `jajelociraptor.tf` file, you can declare your configuration as follows:

```terraform
module "jajelociraptor" {
  source = "./modules/jajelociraptor"
  name   = "Jajelociraptor"
  admin_whitelist = [
    "12.12.12.12"
  ]
  admin_username = "admin"
  admin_email    = "jajemail@jajdomain.com"
  volume_size    = 8
  instance_type  = "t2.large"
}
```

### Some explanations:

- `name`: This will be the name of your project. The resources created will carry this name.
- `admin_whitelist`: The list of IP addresses that will be able to access the Velociraptor frontend (does not apply to clients).
- `admin_username`: The username for logging into the frontend.
- `admin_email`: The email address to receive login information.
- `volume_size`: The size of the instance disk (see https://docs.velociraptor.app/docs/deployment/resources/).
- `instance_type`: The type of EC2 instance (see https://docs.velociraptor.app/docs/deployment/resources/ and https://aws.amazon.com/ec2/instance-types/).

Once the module is configured, you can run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

The email containing the information should arrive within 5 to 10 minutes if you have successfully verified your identity via the Amazon email.

# Additional Information

## If you do not receive an email

It is possible to connect to the EC2 instance via SSM. Here, you will find all server files available in the `/velociraptor/` directory at the root of the disk. As for client files, they are available in an S3 bucket named in the format: `jajelociraptor-NAME_PROJECT-RANDOM_STRING`.

## Reinstalling

To perform a new installation of Velociraptor, I recommend checking the `install_script.sh.tpl` file. This file outlines all the installation lines for Velociraptor.