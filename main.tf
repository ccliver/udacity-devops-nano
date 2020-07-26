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

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id = "S3-udacity-website"
  }

  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-udacity-website"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}