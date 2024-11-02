/*

# Author information

Name: NomDuProfil
Website: valou.io

# Module information

This module will creates an EC2 instance running Velociraptor.

# Variables

| Name            | Type         | Description                                                                                                               |
|-----------------|--------------|---------------------------------------------------------------------------------------------------------------------------|
| name            | string       | Name of the project                                                                                                       |
| admin_whitelist | list(string) | IP address that can access the console                                                                                    |
| admin_username  | string       | Admin username                                                                                                            |
| admin_email     | string       | Email admin (to receive all the information)                                                                              |
| volume_size     | string       | (Optional) Volume size for the EC2 Instance (default: 8GiB) See: https://docs.velociraptor.app/docs/deployment/resources/ |
| instance_type   | number       | (Optional) Instance type (default: t2.micro) See: https://docs.velociraptor.app/docs/deployment/resources/                |

# Example

module "jajelociraptor" {
  source = "./modules/jajelociraptor"
  name   = "JAJELOCIRAPTOR"
  admin_whitelist = [
    "12.12.12.12"
  ]
  admin_username = "admin"
  admin_email    = "jajemail@jajdomain.com"
  volume_size    = 8
  instance_type  = "t2.large"
}

*/
