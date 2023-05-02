provider "aws" {
  region  = "us-east-1"
}

# Zip go code using the archive_file data source
data "archive_file" "function_archive" {
  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}

# Create a lambda function
resource "aws_lambda_function" "test_lambda" {
  function_name    = "tf-test-lambda"
  filename         = local.archive_path
  handler          = "bootstrap"
  source_code_hash = "data.archive_file.function_archive.output_base64sha256"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "provided.al2"
  memory_size      = 128
  timeout          = 10
}

# create a role for the lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# create api gateway rest api resource
resource "aws_api_gateway_rest_api" "api" {
  name = "tf-test-api"
}

# create /hello api gateway resource
resource "aws_api_gateway_resource" "resource" {
  path_part   = "hello"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# create GET method for /hello resource
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# create integration for /hello GET method
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

# create lambda permission for api gateway to invoke lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

# create deployment for api gateway
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"

}

# output api gateway url
output "url" {
  value = "${aws_api_gateway_deployment.api_deploy.invoke_url}${aws_api_gateway_resource.resource.path}"
}
