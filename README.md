<img alt="sctu" src="./www/logo.jpg"/><br/>

[![apply](https://img.shields.io/github/workflow/status/somerville-cambridge-tenants-union/sctu.net/apply?label=apply&logo=github&style=flat-square)](https://github.com/somerville-cambridge-tenants-union/sctu.net/actions)

Source code for [sctu.net](https://www.sctu.net)

## Updating Website from GitHub

Use GitHub's code editor to open [`www/SCTU.md`](https://github.com/somerville-cambridge-tenants-union/sctu.net/edit/master/www/SCTU.md) for editing.

Use the _Preview Changes_ tab to review your changes to the site's copy.

Once you are satisfied, write a commit message describing your change and click the _‹‹Commit changes››_ button.

Next, head over to the [releases](https://github.com/somerville-cambridge-tenants-union/sctu.net/releases) page and draft a new release. Try to follow the existing naming convention of `YYYY.M.D`. Click _‹‹Publish release››_ to publish your changes.

Navigate to [GitHub Actions](https://github.com/somerville-cambridge-tenants-union/sctu.net/actions) and watch your changes get applied!

## Where is the Website Hosted?

This website is a static page hosted using AWS [S3](https://aws.amazon.com/s3/) + [CloudFront](https://aws.amazon.com/cloudfront/). The `sctu.net` domain is managed by [Hover](https://www.hover.com).

The website's files (HTML, CSS, images, etc) are uploaded to an **S3 Bucket** and a **CloudFront Distribution** is configured to serve items in the bucket as static assets for the site.

## Development

GitHub Actions are configured to automatically update the website when a new tag is created, but you can also push changes yourself.

### Prerequisites

Before beginning you will need to install:
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads.html) (optional)

You will also need to configure your AWS credentials in order to access the resources.

### Starting Local Server

Start a local copy of the website on [localhost:8080](http://localhost:8080/) with

```bash
make up
```

(Requires Ruby 2+)

### Sync Files with S3

Sync local files with the S3 Bucket with

```bash
make sync
```

### Clear CloudFront Cache

CloudFront caches files in order to improve performance of the website. After making a change, you must mark the cache as invalid to see your changes (or wait until the cache expires).

```bash
make cachebust
```

### Apply Changes to AWS

You should almost never need to change the resources in AWS, changing the files on S3 should be sufficient. But if you do, you can preview the changes with

```bash
make plan
```

And apply them with

```bash
make apply
```
