<img alt="sctu" src="./www/logo.jpg"/>

Source code for [sctu.net](https://www.sctu.net) website.

## How to Update

Use GitHub's code editor to open [`www/SCTU.md`](https://github.com/somerville-cambridge-tenants-union/sctu.net/edit/master/www/SCTU.md) for editing.

Use the _Preview Changes_ tab to review your changes to the site's copy.

Once you are satisfied, write a commit message describing your change and click the _‹‹Commit changes››_ button.

Next, head over to the [releases](https://github.com/somerville-cambridge-tenants-union/sctu.net/releases) page and draft a new release. Try to follow the existing naming convention of `YYYY.M.D`. Click _‹‹Publish release››_ to publish your changes.

Navigate to [Travis CI](https://travis-ci.com/somerville-cambridge-tenants-union/sctu.net) and watch your changes get applied!

## Development

1. Ensure your AWS keys are properly exported into your environment
2. Run `make plan` to build a Docker image that contains a planfile for terraform
3. Run `make apply` to apply the configuration to AWS
