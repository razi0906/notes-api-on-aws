# 🗒️ AWS Notes API (Serverless CRUD with Auth)

A fully serverless Notes API built using **AWS Lambda**, **API Gateway**, **DynamoDB**, and **Cognito** — all managed via **Terraform**.

---

## 🚀 Overview

This project demonstrates a secure, production-grade REST API setup with:

| Component | Description |
|------------|--------------|
| **AWS Lambda** | Executes CRUD operations on DynamoDB |
| **API Gateway** | Serves REST endpoints and integrates with Lambda |
| **DynamoDB** | Stores note data (`id`, `title`, `content`) |
| **Cognito User Pool** | Handles authentication via JWT |
| **API Key + Usage Plan** | Adds API throttling and access control |
| **Terraform** | Infrastructure as Code (IaC) for the entire stack |

---

## 🧱 Project Structure

```

aws_notes_api/
├── src/
│   └── notes_handler.py        # Lambda handler (CRUD logic)
│
├── terraform/
│   ├── main.tf                 # Providers and backend config
│   ├── lambda.tf               # Lambda + IAM role setup
│   ├── dynamodb.tf             # DynamoDB table definition
│   ├── api_gateway.tf          # API Gateway routes, methods, integrations
│   ├── cognito.tf              # Cognito user pool & client
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Outputs (URLs, keys, tokens)
|   ├── environment.conf.       # Stores environment-specific backend confs
│   └── environment.tfvars      # Environment-specific values
│
└── README.md

````

---

## ⚙️ Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Python 3.12+
- AWS credentials configured (`aws configure`)

---

## 🌍 Setup and Deployment

### 1. Initialize Terraform

```bash
cd terraform
terraform init --backend-config=environment.conf
````

### 2. Plan changes

```bash
terraform plan -var-file=environment.tfvars
```

### 3. Apply configuration

```bash
terraform apply -var-file=environment.tfvars
```

Once deployed, you’ll get outputs like:

```
api_endpoint = "https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/prod/notes"
api_key      = "N78W4sBjNn8TcmaAAL"
```

---

## 👩‍💻 Authentication Setup

### Create a test user in Cognito

```bash
aws cognito-idp admin-create-user \
  --user-pool-id <user_pool_id> \
  --username test_user \
  --temporary-password "Temp@1234"
```

### Authenticate and set a new password

```bash
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id <client_id> \
  --auth-parameters USERNAME=test_user,PASSWORD=Temp@1234
```

You’ll get a `NEW_PASSWORD_REQUIRED` challenge — respond to it:

```bash
aws cognito-idp respond-to-auth-challenge \
  --client-id <client_id> \
  --challenge-name NEW_PASSWORD_REQUIRED \
  --challenge-responses "USERNAME=test_user,NEW_PASSWORD=Test@1234,userAttributes.email=test_user@example.com" \
  --session "<session_token>"
```

This returns your tokens (`IdToken`, `AccessToken`, `RefreshToken`).

---

## 🔐 Testing the API

### List all notes

```bash
curl --location 'https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/notes' \
--header "Authorization: Bearer <IdToken>" \
--header "x-api-key: <api_key>"
```

### Create a new note

```bash
curl -X POST https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/notes \
-H "Authorization: Bearer <IdToken>" \
-H "x-api-key: <api_key>" \
-H "Content-Type: application/json" \
-d '{"title": "First Note", "content": "This is my first note"}'
```

### Update a note

```bash
curl -X PUT https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/notes/<note_id> \
-H "Authorization: Bearer <IdToken>" \
-H "x-api-key: <api_key>" \
-H "Content-Type: application/json" \
-d '{"title": "Updated Note", "content": "Updated content"}'
```

### Delete a note

```bash
curl -X DELETE https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/notes/<note_id> \
-H "Authorization: Bearer <IdToken>" \
-H "x-api-key: <api_key>"
```

---

## 🧠 Notes

* Every code change in `src/` automatically triggers a new Lambda ZIP during `terraform apply`.
* You can view logs via:

  ```bash
  aws logs tail /aws/lambda/notes_handler --follow
  ```
* DynamoDB keys are UUID-based (`uuid4`).

---

## 🧰 Future Enhancements

* Add user-based notes (partition by Cognito `sub` ID)

## ⚙️ Prerequisites

Before deploying or testing the API, ensure you have:

1. ✅ An **AWS account** with access to:

   * Lambda
   * API Gateway
   * Cognito
   * DynamoDB

2. ✅ **AWS CLI** installed and configured

   ```bash
   aws configure
   ```

   Make sure you’re logged in to the correct AWS account/role where resources will be deployed.

3. ✅ **Terraform** installed

   ```bash
   terraform -version
   ```

4. ✅ **Python 3.9+** installed (for Lambda source)

---


## 🧼 Cleanup

To destroy all AWS resources created by Terraform:

```bash
terraform destroy -auto-approve
```

---

## 🧑‍💻 Author

**Razi Ahmed**
Cloud Security & Serverless Developer
*(AWS | Python | GCP | Terraform)*
