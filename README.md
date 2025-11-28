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

flowchart LR
    subgraph VPC["AWS VPC (Private Subnets)"]
        direction LR

        EC2Client["EC2 Client (Optional)\nKafka Tools / Testing"]

        subgraph MSKCluster["Amazon MSK Cluster"]
            Broker1["Broker 1"]
            Broker2["Broker 2"]
            Broker3["Broker 3"]
        end

        DMS["AWS DMS (Optional)\nCDC to Kafka"]

    end

    subgraph GlueETL["(Optional) AWS Glue Jobs"]
        glue1["Data Enrichment / Transform"]
    end

    subgraph Snowflake["Snowflake"]
        SFStage["Snowpipe Streaming"]
        SFTables["Raw + Transformed Tables"]

        subgraph dbt["dbt Core / dbt Cloud"]
            dbtModels["dbt Models\nTransformations"]
        end

        Looker["Looker\nBI & Analytics"]
    end

    AppProducers["Producers\n(Apps, Microservices,\nLambda, IoT, etc.)"]

    AppProducers -->|Produce messages| MSKCluster
    EC2Client -->|Produce/Consume for testing| MSKCluster
    DMS -->|CDC events| MSKCluster

    MSKCluster -->|Kafka Connect\nSnowflake Sink Connector| SFStage
    SFStage --> SFTables
    SFTables --> dbtModels
    dbtModels --> Looker

    glue1 --> SFTables
