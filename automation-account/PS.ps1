$PSVersionTable.PSVersion

terraform -version

az login

az account list -o table --all --query "[].{TenantID: tenantId, Subscription: name, Default: isDefault}"

az account show

az account set --subscription "DTEK PRODUCTION - MSDN"

terraform init

terraform apply main.tfplan

az group show --name "dtek-bold-flea"

terraform plan -destroy -out main.destroy.tfplan

terraform apply main.destroy.tfplan