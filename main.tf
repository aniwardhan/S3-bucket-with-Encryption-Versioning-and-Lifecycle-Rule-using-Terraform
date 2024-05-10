# Create a S3 bucket 
resource "aws_s3_bucket" "my-bucket" {
  bucket = var.bucket-name
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

}

# Define the bucket ownership. Everything inside this bucket is owned by the bucket owner itself
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# By default, new buckets and objects don't allow public access. To Make the bucket public use the code below
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Following code explicitly disables the default S3 bucket security settings. 
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.my-bucket.id
  acl    = "public-read"
}

# Enable Versioning in Bucket
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Uploading index.html file to our bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.my-bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

# Using null resource to push all the files in one time instead of sending one by one
resource "null_resource" "upload-to-S3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/2109_the_card s3://${aws_s3_bucket.my-bucket.id}"
  }
}

# Enable KMS key encryption to S3 bucket (optional)
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.my-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
