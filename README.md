# AWS MSK → Snowflake Replication (Terraform Project)

This project provisions an end-to-end **AWS MSK (Managed Streaming for Apache Kafka)** environment using **Terraform**, including networking, security, logging, Kafka configuration, and an EC2 client instance preconfigured with Kafka tools.

The purpose of this repository is to demonstrate Infrastructure-as-Code (IaC) skills, cloud architecture design, and reproducible development using **VS Code Dev Containers**.

---

## 🚀 Features

### **Infrastructure Provisioning**
Using Terraform, the project creates:

- AWS MSK Cluster  
- MSK Configuration (topics, partitions, replication settings)
- Security Groups (MSK + client)
- CloudWatch log groups for broker logs
- EC2 Kafka client instance  
- Automatic installation of Kafka tools
- Subnet discovery for both public & private subnets
- Encrypted and unauthenticated MSK cluster configuration (demo-friendly)

---

## 🧰 Technologies Used

- **Terraform** (AWS Provider)
- **AWS MSK**
- **AWS EC2**
- **AWS CloudWatch Logs**
- **AWS CLI**
- **Docker Dev Containers (VS Code)**

---

## 📁 Project Structure

```
aws-msk-snowflake-replication/
├── .devcontainer/
│ ├── devcontainer.json # VS Code Dev Container setup
│ ├── Dockerfile # Custom image with Terraform + AWS CLI
├── msk/
│ ├── datasources.tf # VPC subnet data sources
│ ├── init_no_client_auth_encrypt.sh # Kafka EC2 initialization script
│ ├── main.tf # MSK cluster, SGs, EC2 instance
│ ├── outputs.tf # Exported values
│ └── variables.tf # Input variables
├── dev_msk.env # TF_VAR_* environment variables
└── .gitignore

```

---

## 🐳 Dev Container Setup (Recommended)

This repository includes a **VS Code Dev Container** so the environment is fully reproducible and isolated.

### **Dev Container Includes**
- Terraform CLI
- AWS CLI
- jq, python3, unzip
- Terraform VS Code extensions
- Automatic injection of `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from your host OS

### **How to Use**

1. Install:
   - VS Code
   - Dev Containers extension
   - Docker Desktop

2. Open the project folder in VS Code.

3. When prompted →  
   **“Reopen in Dev Container”**

4. Verify AWS credentials are available:

```bash
aws sts get-caller-identity
```

## 🔧 Configuration

### AWS Credentials & Terraform Variable (Environment Variables)
All variables are loaded from dev_msk.env using the TF_VAR_ prefix.

Example:
```bash
export TF_VAR_region=us-east-1
export TF_VAR_environment=dev
export TF_VAR_vpc_id=vpc-05eb5ffe616347613
...
```

Load them inside the dev container:

```bash
source dev_msk.env
source .env
```
Verify:

```bash
echo $TF_VAR_region
```


## ▶️ Deploying the MSK Cluster

Run the following inside the dev container:

```bash
cd msk/
terraform init
terraform plan
terraform apply
```

Terraform will:

Configure the backend in S3

Deploy the MSK cluster

Provision security groups

Launch the EC2 Kafka client

Apply MSK server properties

## 📤 Outputs

After provisioning, Terraform prints:

MSK cluster details

MSK security group ID

Private subnet IDs

Example:

```bash
private_subnet_ids = [...]
msk_security_group_id = "sg-xxxxx"
msk_cluster = { ... }
```

## 📘 Notes

- The EC2 instance automatically installs Kafka 3.2.0.

- Client → broker traffic is PLAINTEXT (demo only, not production).

- Update kafka_version to a specific number (e.g., 3.8.1) if required by AWS MSK.

## 🗑 Destroying All Resources

```bash
terraform destroy
```

## 🙋‍♂️ Author

JC Carhuarica
Cloud & Data Engineer