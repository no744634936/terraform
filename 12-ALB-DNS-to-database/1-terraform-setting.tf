terraform {
  //required_version = "~> 0.14"   # which means any version equal & above 0.14 like 0.15, 0.16 etc and < 1.xx
  required_version = "~> 1.2.2"     # which means any version equal & above 1.2.2 like 1.2.3, 1.2.4 etc and < 1.3.xx
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.31.0"
    }

    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }   
  }
}

# "aws" 与 required_providers里的aws 同名
# profile = "default" 可以不写，它指的是cat $HOME/.aws/credentials 里设定的默认的access key
provider "aws"{
  region  = var.aws_region
  profile = "default"
}