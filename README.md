# General

This is an demostration of End to End CD and CI for a Single Page Application.

## Tech Stacks

- Angular(version - 14)
- AWS Components
  - S3 to deploy the application and upload the object
  - CodeCommit to store the application and infrastructure code
  - CodeBuild to deploy the application as SPA in S3 and Cloudfront
  - CodePipeline to create automated pipelines for enabling CD CI
- IaaC ( Terraform)

### Solution Design

- Solution Design of the E2E Pipeline: ![Alt text](solution_design/CodeCommit.png?raw=true "Code-Commit")

- Solution Design of the Single Page Application: ![Alt text](solution_design/SPA.png?raw=true "Single Page Application")

### Replace the following values

- AWS Account ID
- AWS Cognito Identity Pool ID
- AWS S3 Upload and Website Hosting Bucket
- AWS CodeCommit Repo and branch

### Additional things to be added(requires extra cost)

- Valid Domain to host the website
- AWS Route53 Domain validation setup
