variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}
 
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
default = "10.0.0.0/16"
}
 
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
default = "10.0.1.0/24"
}
 
variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
default = "10.0.2.0/24"
}
 
variable "s3_bucket_name" {
  description = "S3 bucket name for Lambda code"
  default     = "my-lambda-code-bucket"
}
 
variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  default     = "my-dynamodb-table"
}
 
variable "lambda_function1_name" {
  description = "Name of the first Lambda function"
  default     = "my-lambda-function1"
}
 
variable "lambda_function2_name" {
  description = "Name of the second Lambda function"
  default     = "my-lambda-function2"
}
 
variable "api_gateway_name" {
  description = "API Gateway name"
  default     = "my-api-gateway"
}