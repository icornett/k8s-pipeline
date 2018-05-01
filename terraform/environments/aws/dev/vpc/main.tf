module "vpc" {
  source           = "../../../../modules/aws/vpc/"
  project_name     = "k8s-aws-pipeline"
  environment_name = "dev"
}

terraform {
  backend "s3" {
    bucket         = "k8s-aws-pipeline"
    dynamodb_table = "k8s-aws-pipeline-dev-lock"
    key            = "dev/vpc.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}
