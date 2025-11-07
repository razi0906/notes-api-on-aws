##########################
# API Gateway REST API
##########################
resource "aws_api_gateway_rest_api" "notes_api" {
  name        = "NotesAPI"
  description = "API for CRUD Notes"
}

##########################
# Resources
##########################
# /notes
resource "aws_api_gateway_resource" "notes" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id
  parent_id   = aws_api_gateway_rest_api.notes_api.root_resource_id
  path_part   = "notes"
}

# /notes/{id}
resource "aws_api_gateway_resource" "note_id" {
  rest_api_id = aws_api_gateway_rest_api.notes_api.id
  parent_id   = aws_api_gateway_resource.notes.id
  path_part   = "{id}"
}

##########################
# Methods
##########################
# GET /notes
resource "aws_api_gateway_method" "get_notes" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  resource_id   = aws_api_gateway_resource.notes.id
  http_method   = "GET"
  api_key_required = true
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.notes_auth.id
}

# POST /notes
resource "aws_api_gateway_method" "post_notes" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  resource_id   = aws_api_gateway_resource.notes.id
  http_method   = "POST"
  api_key_required = true
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.notes_auth.id
}

# GET /notes/{id}
resource "aws_api_gateway_method" "get_note_id" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  resource_id   = aws_api_gateway_resource.note_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.notes_auth.id
  api_key_required = true
}

# PUT /notes/{id}
resource "aws_api_gateway_method" "put_note_id" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  resource_id   = aws_api_gateway_resource.note_id.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.notes_auth.id
  api_key_required = true
}

# DELETE /notes/{id}
resource "aws_api_gateway_method" "delete_note_id" {
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  resource_id   = aws_api_gateway_resource.note_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.notes_auth.id
  api_key_required = true
}

##########################
# Lambda Integrations
##########################
resource "aws_api_gateway_integration" "get_notes" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.notes.id
  http_method             = aws_api_gateway_method.get_notes.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notes_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_notes" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.notes.id
  http_method             = aws_api_gateway_method.post_notes.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notes_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_note_id" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.note_id.id
  http_method             = aws_api_gateway_method.get_note_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notes_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "put_note_id" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.note_id.id
  http_method             = aws_api_gateway_method.put_note_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notes_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "delete_note_id" {
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  resource_id             = aws_api_gateway_resource.note_id.id
  http_method             = aws_api_gateway_method.delete_note_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.notes_lambda.invoke_arn
}

##########################
# Deployment & Stage
##########################
resource "aws_api_gateway_deployment" "notes_api_deploy" {
  depends_on = [
    aws_api_gateway_integration.get_notes,
    aws_api_gateway_integration.post_notes,
    aws_api_gateway_integration.get_note_id,
    aws_api_gateway_integration.put_note_id,
    aws_api_gateway_integration.delete_note_id,
    aws_api_gateway_authorizer.notes_auth,
    aws_api_gateway_method.get_notes,
    aws_api_gateway_method.post_notes,
    aws_api_gateway_method.get_note_id,
    aws_api_gateway_method.put_note_id,
    aws_api_gateway_method.delete_note_id
  ]

  rest_api_id = aws_api_gateway_rest_api.notes_api.id

  triggers = {
    redeployment = sha1(join("", [for f in fileset(path.module, "*.tf") : filesha1(f)]))
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.notes_api.id
  deployment_id = aws_api_gateway_deployment.notes_api_deploy.id
  lifecycle {
    # Prevent Terraform from trying to delete stage before deployment
    create_before_destroy = true
  }
}

##########################
# API Key & Usage Plan
##########################
resource "aws_api_gateway_api_key" "notes_api_key" {
  name    = "NotesAPIKey"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "notes_usage_plan" {
  name = "NotesUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.notes_api.id
    stage  = aws_api_gateway_stage.prod_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_key" {
  key_id        = aws_api_gateway_api_key.notes_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.notes_usage_plan.id
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "notes_auth" {
  name                    = "notes_auth"
  rest_api_id             = aws_api_gateway_rest_api.notes_api.id
  type                    = "COGNITO_USER_POOLS"
  provider_arns           = [aws_cognito_user_pool.notes_user_pool.arn]
  identity_source         = "method.request.header.Authorization"
}
