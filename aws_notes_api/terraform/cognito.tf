resource "aws_cognito_user_pool" "notes_user_pool" {
  name = "notes_user_pool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "notes_user_pool_client" {
  name         = "notes_user_pool_client"
  user_pool_id = aws_cognito_user_pool.notes_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  generate_secret                        = false
  allowed_oauth_flows                    = ["implicit", "code"]
  allowed_oauth_scopes                   = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client   = true
  supported_identity_providers           = ["COGNITO"]
  callback_urls                          = ["http://localhost:3000"]
  logout_urls                            = ["http://localhost:3000"]
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.notes_user_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.notes_user_pool_client.id
}
