# General

Terraform Script to create the following AWS Service

- AWS S3 Website Hosting for the input bucket
- AWS CloudFront Distribution for the Website
- AWS CodePipeline to host the CD/CI for the whole stack
- AWS Codebuild to deploy the changes and invalidate the AWS Cloudfront Caches
- AWS SNS Topic to notify the pipeline changes
- AWS Email Subscription to the SNS topic to notify the pipeline changes

## Replace the following values

- AWS S3 Upload and Website Hosting Bucket
- AWS CodeCommit Repo and branch

### Execute the Terrafrom Scripts

- Validate and Run the script

``
 terrafrom plan 
``\
``
 terraform apply
``

- Some Useful commands

``
find . -name '*.tf' | xargs -L1 terraform fmt
``
