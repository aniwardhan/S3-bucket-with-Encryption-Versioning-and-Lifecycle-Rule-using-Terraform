# Create-S3-bucket-with-Encryption-and-Versioning-enabled

## Objective:

The goal of this project is to create an Amazon S3 bucket with server-side encryption and versioning enabled using Terraform. This ensures secure storage of data with automatic data version control, allowing for easy recovery of earlier versions in case of accidental deletion or corruption.

## Required Skills and Tools:

* Terraform and IaC experience.
  
* Basic knowledge of AWS services, specifically Amazon S3.
  
* Understanding of security best practices for AWS S3.
  
* Ability to implement and test infrastructure changes using Terraform.

## Step 1: Define [provider.tf](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/blob/main/provider.tf) file

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}
```

## Step 2: [Create S3 bucket](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/blob/main/main.tf)

```hcl
# Create a S3 bucket 
resource "aws_s3_bucket" "my-bucket" {
  bucket = var.bucket-name
}
```

Using the resource block, we've defined a new resource of type **aws_s3_bucket**. This tells Terraform that we want to create a new S3 bucket in our AWS account.

Inside the aws_s3_bucket block, we've specified the name of our bucket using the bucket field. The name is reference from the variable file

**[variable.tf](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/blob/main/variable.tf)** 

```hcl
# declare a variable to define the region name
variable "aws_region" {
    description = "Mention the region name"
    type = string
    default = "us-east-1"
}

# declare a variable to define the name of the S3 bucket
variable "bucket-name" {
    description = "S3 name defined uniquely"
    type = string
    default = "mybucket-terraform2024"
  
}
```

The basic configuration to create a bucket is done. Run the ```terraform init``` command to initialize the working directory and download the required providers.

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/0a27d5c9-19ef-4e03-88fb-76da0fa10778)

Now, use ```terraform plan``` which creates an execution plan by analyzing the changes required to achieve the desired state of your infrastructure

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/4b0b738b-969d-4e8c-b15d-6be3f87da1e5)

Finally, use ```terraform apply ``` to apply the changes to create or update resources.

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/09211e43-8bd1-4a76-9443-815dbfda973b)

S3 bucket successfully created in AWS Console

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/367fc4f8-8302-4cd7-9f81-716b75290154)

## Step 3: Configure the bucket to allow public read access 

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/32c12bb3-0ada-40d2-865d-3c8a92269d0d)

This example explicitly disables the default S3 bucket security settings. This should be done with caution, as all bucket objects become publicly exposed.

```hcl
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.my-bucket.id
  acl    = "public-read"
}
```

Apply the changes to check the output in console

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/3eee29ee-b98f-4279-9f7b-3b137d024fe6)

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/0cf20edd-f848-4e9a-8217-084a51c7f0a1)

## Step 4: Create an S3 bucket policy that allows read-only access to a specific IAM user or role

create a file **[iampolicy.tf](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/blob/main/iampolicy.tf)** and add the code below

```hcl
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.my-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"] # add your AWS account number
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.my-bucket.arn,
      "${aws_s3_bucket.my-bucket.arn}/*",
    ]
  }
}
```
Bucket Policy added

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/9b5a26af-953d-4b95-b020-23f16bad3b5c)

## Step 5: Upload single file into S3 bucket

The below code uploads single file into the bucket. For example we have uploaded **[index.htm](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/blob/main/index.html)** file 

```hcl
# Uploading index.html file to our bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.my-bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}
```

run ```terraform apply -auto-approve``` to check the output

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/6818227d-d5a3-4c6d-a1ad-a46397c1f97f)

Check the AWS Console

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/26ce4c59-6753-4115-b5d2-90291f0bd084)


## Step 6: Upload entire project folder into S3 bucket  (upload multiple files at a time)

Copy the folder into your local working directory

```hcl
# Using null resource to push all the files in one time instead of sending one by one
resource "null_resource" "upload-to-S3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/2109_the_card s3://${aws_s3_bucket.my-bucket.id}"
  }
}
```

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/768cf11f-01d8-492e-bf81-b13934da605f)


## Step 7: Enable versioning on the S3 bucket **Resource: aws_s3_bucket_versioning**

Provides a resource for controlling versioning on an S3 bucket. Deleting this resource will either suspend versioning on the associated S3 bucket or simply remove the resource from Terraform state if the associated S3 bucket is unversioned.

```hcl
# Enable Versioning in Bucket

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

Versioning Enabled

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/0f96de0f-015f-440b-ab13-5ecd3ae6ca24)

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/8971cf64-a02d-4992-b3d4-d414056636a8)


## Step 8: aws_s3_bucket_server_side_encryption_configuration

```hcl
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
```

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/baa08d4f-d212-41e6-9e0a-c0cea0fdff39)

## Step 9: Add Lifecycle Configuration

* **Lifecycle Configuration:** Users can define or specify lifecycle rules for their own S3 buckets through lifecycle configuration settings. These principles indicate moves to be made on 
    objects as they age.
* **Transition Actions:** Transition Actions figure out what happens to objects as they arrive at determined stages in their lifecycle. For instance, items can be consequently changed to lower- 
    cost capacity classes like S3 Standard-IA or Icy mass to diminish storage costs.
* **Expiration Actions:** Expiration Actions characterize when objects should to be consequently deleted from the bucket. Items can be designed to lapse following a specific number of days since 
    creation or since the objects last modification.

 ```hcl
  # Define lifecycle policy
  resource "aws_s3_bucket_lifecycle_configuration" "example_lifecycle" {
  bucket = aws_s3_bucket.my-bucket.id

  rule {
    id = "rule1"
    filter {
      prefix = "logs/" # You can set your prefix here
    }

    # Transition rule
    transition {
      days          = 30 # Update the transition days as per your requirement
      storage_class = "GLACIER"
    }

    # Expiration rule
    expiration {
      days = 60 # Update the expiration days as per your requirement
    }

    # Status
    status = "Enabled"
  }
}
```

![image](https://github.com/aniwardhan/S3-bucket-with-Encryption-Versioning-and-Lifecycle-Rule/assets/80623694/93658909-9921-44c7-b259-8dae8ea7aec1)

## Step 9: Clean the resources

Apply ```terraform destroy -auto-approve``` to clean all the resources created

When trying to delete a bucket with versioning enabled, you get the following error

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/29ea1686-5557-4338-9f2d-0347ea1b00a1)

Fix this with the below code

```hcl
# Create a S3 bucket 

resource "aws_s3_bucket" "my-bucket" {
  bucket = var.bucket-name
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}
```

![image](https://github.com/aniwardhan/Create-S3-bucket-with-Encryption-and-Versioning-enabled/assets/80623694/613fef45-4fd3-4870-882c-1426fad246e5)
