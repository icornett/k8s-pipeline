module "remoteState" {
  source           = "../../../../modules/aws/state"
  environment_name = "dev"
  project_name     = "k8s-aws-pipeline"
}
