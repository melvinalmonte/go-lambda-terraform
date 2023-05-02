# Deploying a Hello World Lambda with Terraform

This project provides a reference for deploying a simple "Hello World" AWS Lambda function written in Go using Terraform. The project consists of two directories: `app` and `infra`.

## Requirements

To deploy this project, you'll need:

- An AWS account with appropriate permissions to create resources
- AWS CLI installed and configured with valid credentials
- Terraform installed on your local machine

## Project Structure

```
.
├── app
│   └── main.go
|   └── Makefile 
└── infra
    ├── locals.tf
    └── main.tf
```

- `app/main.go`: contains the code for the "Hello World" Lambda function.
- `app/Makefile`: contains a `build` target for building the Lambda function.
- `infra/main.tf`: defines the AWS resources to be created, including the Lambda function and the IAM role with the necessary permissions for the function to execute.
- `infra/locals.tf`: contains local variables used in `main.tf`.

## Deployment Instructions

1. Clone the repository: `git clone https://github.com/example/hello-lambda-terraform.git`
2. Navigate to the `app` directory: `cd hello-lambda-terraform/app`
3. Install go dependencies: `go mod tidy`
4. Build the Lambda function: `make build` 
5. Navigate to the `infra` directory: `cd hello-lambda-terraform/infra`
6. Initialize the Terraform backend: `terraform init`
7. Preview the changes Terraform will make: `terraform plan`
8. Deploy the changes: `terraform apply`
9. The output of the `terraform apply` command will include our newly created API Gateway URL 
## Clean Up

To delete the resources created by this project, run `terraform destroy` from the `infra` directory.
