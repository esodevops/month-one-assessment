# TechCorp AWS Infrastructure – Terraform Assessment

  - Provisions a highly-available (HA), secure web-application stack on AWS using Terraform.

## Architecture Overview

```
Internet
   │
   ▼
┌─────────────────────────────────────────────────────────────┐
│  Application Load Balancer  (public subnets – 2 AZs)        │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP :80
          ┌──────────────┴──────────────┐
          ▼                             ▼
┌─────────────────┐           ┌─────────────────┐
│  Web Server 1   │           │  Web Server 2   │
│ (private AZ-1)  │           │ (private AZ-2)  │
└────────┬────────┘           └────────┬────────┘
         │ PostgreSQL :5432            │
         ▼                             │
┌─────────────────┐                    │
│  DB Server      │◄──────────────────-┘
│ (private AZ-1)  │
└─────────────────┘

┌─────────────────┐
│  Bastion Host   │◄── Your IP only (SSH :22)
│ (public AZ-1)   │
│  [Elastic IP]   │──► Web/DB servers (SSH :22)
└─────────────────┘
```

## File Structure

```
terraform-assessment/
├── main.tf                      # All AWS resources
├── variables.tf                 # Input variable declarations
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Template – copy to terraform.tfvars
├── user_data/
│   ├── web_server_setup.sh      # Apache install + admin user bootstrap
│   └── db_server_setup.sh       # PostgreSQL install + admin user bootstrap
├── evidence
│   ├── plan_output.md           # Saved output of `terraform plan`
│   ├── apply_output.md          # Saved output of `terraform apply`
│   ├── Resources.md             # AWS Resources Created
└── README.md                    # This file
```

## Quick Start

### 1. Clone this directory

```bash
git clone https://github.com/esodevops/month-one-assessment.git
cd month-one-assessment
```

### 2. Configure your variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and fill:

| Variable | Description |
|----------|-------------|
| `my_ip` | Your public IP in CIDR form, e.g. `"203.0.113.10/32"` |
| `admin_password` | Password for the admin OS user on web/DB servers |
| `key_name` | Existing EC2 Key Pair name (or `""` for password-only) |

```bash
Find your public IP: `curl -s ifconfig.me`
```

### 3. Initialise Terraform

```bash
terraform init
```

### 4. Format main.tf

```bash
terraform fmt
```

### 5. Check for main.tf accuracy 

```bash
terraform validate
```

### 6. Preview the plan

```bash
terraform plan
```

### 7. Apply

```bash
terraform apply | Answer yes to continue
terraform apply -auto-approve
```

## SSH Access

### Connecting to the Bastion Host

```bash
# With key pair
ssh -i ~/.ssh/<your-key.pem> ec2-user@<bastion_public_ip>

# Without key pair (password auth enabled on Bastion via Amazon Linux default)
ssh ec2-user@<bastion_public_ip>
```

### Connecting to Web / DB Servers via Bastion

The web and database servers use **username + password** authentication.

```bash
# From your workstation – open a tunnel via the Bastion
ssh -J ec2-user@<bastion_public_ip> ec2-user@<web_server_1_private_ip>

# Or: SSH to Bastion first, then hop to the target
ssh -i ~/.ssh/<your-key.pem> ec2-user@<bastion_public_ip>
[bastion]$ ssh ec2-user@10.0.3.x          # web server 1
[bastion]$ ssh ec2-user@10.0.4.x          # web server 2
[bastion]$ ssh ec2-user@10.0.3.x          # db server (same AZ-1 subnet)
```

Use the password set in `admin_password`.


### Run PostgreSQL Commands in DB Server

```bash
sudo -u postgres -i
psql
ALTER USER postgres WITH PASSWORD 'dbpass123#';
CREATE DATABASE techcorp_db;

\l              -- List all databases
\c dbname       -- Connect to a database
\dt             -- List tables
\d tablename    -- Describe table structure
\du             -- List users/roles
\q              -- Quit psql
```

### Exporting Terraform State to s3 Bucket

```bash
aws s3 mb s3://techcorp-state-bkt --region us-east-1
terraform init
terraform apply
```

### Copy existing terraform state file to s3 bucket
```bash
aws s3 cp terraform.tfstate s3://techcorp-state-bkt/terraform/backend/terraform.tfstate
```

## Evidence

```bash
terraform plan -no-color > evidence/plan_output.md
terraform apply -auto-approve -no-color > evidence/apply_output.md
```

## Teardown Infrastructure

```bash
terraform destroy
terraform destroy -auto-approve
```
