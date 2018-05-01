resource "aws_dynamodb_table" "state-lock-table" {
  name           = "${var.project_name}-${var.environment_name}-lock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "state-storage" {
  bucket = "${var.project_name}-state"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_s3_bucket" "selected" {
  bucket = "${aws_s3_bucket.state-storage.id}"
}
