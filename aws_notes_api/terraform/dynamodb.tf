resource "aws_dynamodb_table" "notes" {
  name         = "Notes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "NotesTable"
    Project = "AWS Notes API"
  }
}
