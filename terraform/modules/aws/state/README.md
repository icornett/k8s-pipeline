# Remote State Server with Locking

## Variables

- __AWS_ACCESS_KEY__
  - Access credential for AWS

- __AWS_SECRET_KEY__
  - Secret credential for AWS

- __AWS_REGION__
  - Region to deploy assets to, defaults to US West 2 (Oregon)

- __project_name__
  - The name of the project being run

- __environment_name__
  - Environment being deployed, defaults to prod

## Resources Created

- __aws_s3_bucket.state-bucket__
  - Creates S3 bucket
    - Versioning Enabled
    - Server-side encryption enabled using default KMS key
- __aws_dynamo_db_table.state-lock-table__
  - Creates Dynamo locking table to prevent concurrent/conflicting activities

## Outputs

- __state_bucket__
  - Name of state bucket created