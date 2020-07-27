az login

az account list --output table

az account set --subscription "<Azure-SubscriptionId>"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID" --name="Azure-DevOps"


#appId (Azure) → client_id (Terraform).
#password (Azure) → client_secret (Terraform).
#tenant (Azure) → tenant_id (Terraform).
