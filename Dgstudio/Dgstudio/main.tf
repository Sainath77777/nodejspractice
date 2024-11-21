provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "demovpc" {
  cidr_block = var.vpc_cidr
}
 
resource "aws_subnet" "subnet1a" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block        = var.subnet1a_cidr
  availability_zone = "us-east-1a"
}
 
resource "aws_subnet" "subnet1b" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block        = var.subnet1b_cidr
  availability_zone = "us-east-1b"
}
 
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private" 
}
 
resource "aws_dynamodb_table" "my_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
 
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
Service = "lambda.amazonaws.com"
      }
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
role = aws_iam_role.lambda_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
 
resource "aws_iam_role_policy_attachment" "dynamodb_access_policy" {
role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data 
 
resource "aws_lambda_function" "lambda_function1" {
  function_name = var.lambda_function1_name
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  s3_bucket     = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key = "lambda_function1.zip"
 
  environment {
    variables = {
TABLE_NAME = aws_dynamodb_table.my_table.name
    }
  }
}

resource "aws_lambda_function" "lambda_function2" {
  function_name = var.lambda_function2_name
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  s3_bucket     = aws_s3_bucket.lambda_code_bucket.bucket
s3_key = "lambda_function2.zip"
 
  environment {
    variables = {
TABLE_NAME = aws_dynamodb_table.my_table.name
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_gateway_name
}
 
resource "aws_api_gateway_resource" "resource" {
rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "lambda"
}
 
resource "aws_api_gateway_method" "get_method" {
rest_api_id = aws_api_gateway_rest_api.api.id
resource_id = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}
 
resource "aws_api_gateway_integration" "lambda_integration" {
rest_api_id = aws_api_gateway_rest_api.api.id
resource_id = aws_api_gateway_resource.resource.id
  http_method            = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.lambda_function1.invoke_arn
}
 
