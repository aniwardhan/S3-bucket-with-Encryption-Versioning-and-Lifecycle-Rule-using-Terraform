
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


