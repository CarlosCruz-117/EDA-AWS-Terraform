🏛️ AWS architecture defined using Terraform:
**AWS WAF ➜ API Gateway (REST) ➜ EventBridge (Custom Bus) ➜ SQS (+ DLQ)**

### 📜 Evolution
### v1.0
- API Gateway → Lambda → SQS
- Basic functional architecture
### v1.1
- Removal of Lambda
- Request validation (API GW)
### v1.2
- Refactor event-based filtering rules (Cloudwatch)
### v2.0
- Security enhancement: WAF
### v3.0
- Event filtering (content-based routing)
- Added SQS DLQ

__________________________________________________________

🚀 Deploy
```bash
terraform init
terraform plan
terraform apply
