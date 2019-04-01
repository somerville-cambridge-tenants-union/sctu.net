provider aws {
  profile = "mcc"
  region  = "us-east-1"
  version = "~> 2.4"
}

resource aws_acm_certificate cert {
  domain_name       = "${aws_s3_bucket.sctu.bucket}"
  validation_method = "DNS"
}

resource aws_cloudfront_distribution s3_distribution {
  aliases             = ["sctu.net", "www.sctu.net"]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = "${aws_s3_bucket.sctu.bucket}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = "${aws_s3_bucket.sctu.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.sctu.bucket}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.cert.arn}"
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

resource aws_s3_bucket sctu {
  acl           = "public-read"
  bucket        = "sctu.net"
  force_destroy = false
}
