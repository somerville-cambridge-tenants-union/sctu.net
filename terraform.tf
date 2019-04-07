terraform {
  backend s3 {
    bucket = "sctu.net"
    key    = "sctu.net.tfstate"
    region = "us-east-1"
  }
}

provider aws {
  access_key = "${var.aws_access_key_id}"
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
  secret_key = "${var.aws_secret_access_key}"
  version    = "~> 2.5"
}

locals {
  domain_name = "sctu.net"
  html        = ["error", "index"]

  tags {
    App     = "sctu"
    Name    = "${local.domain_name}"
    Release = "${var.release}"
    Repo    = "${var.repo}"
  }
}

data aws_iam_policy_document website {
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::www.${local.domain_name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.website.iam_arn}"]
    }
  }
}

data aws_acm_certificate cert {
  domain   = "${local.domain_name}"
  statuses = ["ISSUED"]
}

resource aws_cloudfront_distribution website {
  aliases             = ["${local.domain_name}", "www.${local.domain_name}"]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = "${aws_s3_bucket.website.bucket}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = "${aws_s3_bucket.website.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.website.bucket}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${data.aws_acm_certificate.cert.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource aws_cloudfront_origin_access_identity website {
  comment = "access-identity-www.${local.domain_name}.s3.amazonaws.com"
}

/*
resource aws_route53_record a {
  name    = "${local.domain_name}"
  type    = "A"
  zone_id = "${aws_route53_zone.website.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website.hosted_zone_id}"
  }
}

resource aws_route53_record aaaa {
  name    = "${local.domain_name}"
  type    = "AAAA"
  zone_id = "${aws_route53_zone.website.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website.hosted_zone_id}"
  }
}

resource aws_route53_record www_a {
  name    = "www.${local.domain_name}"
  type    = "A"
  zone_id = "${aws_route53_zone.website.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website.hosted_zone_id}"
  }
}

resource aws_route53_record www_aaaa {
  name    = "www.${local.domain_name}"
  type    = "AAAA"
  zone_id = "${aws_route53_zone.website.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.website.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website.hosted_zone_id}"
  }
}
*/

resource aws_s3_bucket website {
  acl           = "private"
  bucket        = "www.${local.domain_name}"
  force_destroy = false
  policy        = "${data.aws_iam_policy_document.website.json}"
  tags          = "${local.tags}"

  website {
    error_document = "error.html"
    index_document = "index.html"
  }
}

resource aws_s3_bucket_object css {
  acl          = "private"
  bucket       = "${aws_s3_bucket.website.bucket}"
  content      = "${file("www/main.css")}"
  content_type = "text/css"
  etag         = "${filemd5("www/main.css")}"
  key          = "main.css"
  tags         = "${local.tags}"
}

resource aws_s3_bucket_object html {
  count        = "${length(local.html)}"
  acl          = "private"
  bucket       = "${aws_s3_bucket.website.bucket}"
  content      = "${file("www/${element(local.html, count.index)}.html")}"
  content_type = "text/html"
  etag         = "${filemd5("www/${element(local.html, count.index)}.html")}"
  key          = "${element(local.html, count.index)}.html"
  tags         = "${local.tags}"
}

resource aws_s3_bucket_object jpg {
  acl            = "private"
  bucket         = "${aws_s3_bucket.website.bucket}"
  content_base64 = "${base64encode(file("www/logo.jpg"))}"
  content_type   = "image/jpeg"
  etag           = "${filemd5("www/logo.jpg")}"
  key            = "logo.jpg"
  tags           = "${local.tags}"
}

resource aws_s3_bucket_object sctu {
  acl          = "private"
  bucket       = "${aws_s3_bucket.website.bucket}"
  content      = "${file("www/SCTU.md")}"
  content_type = "text/markdown"
  etag         = "${filemd5("www/SCTU.md")}"
  key          = "SCTU.md"
  tags         = "${local.tags}"
}

resource aws_s3_bucket_object otf {
  acl            = "private"
  bucket         = "${aws_s3_bucket.website.bucket}"
  content_base64 = "${base64encode(file("www/MonumentExtended-Ultrabold.otf"))}"
  content_type   = "application/x-font-opentype"
  etag           = "${filemd5("www/MonumentExtended-Ultrabold.otf")}"
  key            = "MonumentExtended-Ultrabold.otf"
  tags           = "${local.tags}"
}

variable aws_access_key_id {
  description = "AWS Access Key ID."
  default     = ""
}

variable aws_secret_access_key {
  description = "AWS Secret Access Key."
  default     = ""
}

variable aws_profile {
  description = "AWS Profile."
  default     = ""
}

variable aws_region {
  description = "AWS Region."
  default     = "us-east-1"
}

variable release {
  description = "Release tag."
}

variable repo {
  description = "Project repository."
  default     = "https://github.com/somerville-cambridge-tenants-union/sctu.net"
}

output bucket_name {
  description = "S3 website bucket name."
  value       = "${aws_s3_bucket.website.bucket}"
}

output cloudfront_distribution_id {
  description = "CloudFront distribution ID."
  value       = "${aws_cloudfront_distribution.website.id}"
}
