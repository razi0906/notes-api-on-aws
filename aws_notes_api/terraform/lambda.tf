# Package Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda_package.zip"
  excludes    = ["__pycache__"]
}

# Lambda Function
resource "aws_lambda_function" "notes_lambda" {
  function_name    = "notes_handler"
  handler          = "notes_handler.lambda_handler" # file_name.function_name
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.notes.name
    }
  }
}


resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notes_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.notes_api.execution_arn}/*/*"
}
