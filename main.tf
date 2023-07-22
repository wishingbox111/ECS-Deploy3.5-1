#source file from https://github.com/terraform-aws-modules/terraform-aws-ecs
#customised code used from https://github.com/jaezeu/hello-node/blob/main/terraform/main.tf

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["sandbox-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-tf-chen"   #Change to your unique name

  fargate_capacity_providers = { #this is where it shows how much % use Fargate, how much % use Fargate spot instances!
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    enchen_ecsdemo = { #task def and service name -> #Change to unique name
      cpu    = 512
      memory = 1024

      # Container definition(s)
      container_definitions = {

        ecs-sample_chen = { #container name #tried changing name too
          essential = true 
          image     = "public.ecr.aws/docker/library/httpd:latest"
          port_mappings = [
            {
              name          = "ecs-sample_chen"  #container name #tried changing too
              containerPort = 80
              protocol      = "tcp"
            }
          ]
          readonly_root_filesystem = false

        }
      }
      assign_public_ip = true
      deployment_minimum_healthy_percent = 100
      subnet_ids = flatten(data.aws_subnets.public.ids)
      security_group_ids  = ["sg-01adb0fa94b766534"]
    }
  }
}