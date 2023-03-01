
resource "aws_s3_bucket" "mdm_mauro_terraform_state" {
  bucket = "mdm-mauro-terraform-state-prod"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "mdm_versioning" {
  bucket  = aws_s3_bucket.mdm_mauro_terraform_state.id

  versioning_configuration  {
    status  = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mdm_s3_encryption" {
  bucket  = aws_s3_bucket.mdm_mauro_terraform_state.id

  rule  {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "mdm_s3_public_access" {
  bucket = aws_s3_bucket.mdm_mauro_terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "mdm_tf_locks" {
  name  = "mdm-tf-locks-prod"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key  = "LockID"

  attribute {
    name  = "LockID"
    type  = "S"
  }
}