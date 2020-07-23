provider "aws" {
  region = var.region
}


resource "random_string" "string" {
  length  = 6
  lower   = true
  number  = false
  upper   = false
  special = false
}

resource "aws_s3_bucket" "website" {
  bucket = "udacity-project-1-${var.region}-${random_string.string.result}"
  acl = "public-read"

  website {
    index_document = "index.html"
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::udacity-project-1-${var.region}-${random_string.string.result}/*"]
    }
  ]
}
POLICY
}
