# confluent-to-redshift-upserts

This is a short demo that shows how to use a Lambda function to handle row level updates in a Redshift Serverless cluster. The function reads input events from a Confluent Cloud topic and uses Update DML to update individual rows in Redshift.

├── Terraform                             <-- Demo terraform script and artifacts
│   ├── terraform.tf                      <-- Terraform for AWS resources
│   ├── redshift_upsert_lambda.zip        <-- Zip file for upsert lambda function code.

## General Requirements

* **Confluent Cloud Cluster and API Keys** - API Keys should be added to Secrets Manager. For more information, check [this](https://docs.aws.amazon.com/msk/latest/developerguide/msk-password.html) out.
* **Terraform (0.14+)** - The application is automatically created using [Terraform](https://www.terraform.io). Besides having Terraform installed locally, will need to provide your cloud provider credentials so Terraform can create and manage the resources for you.
* **AWS CLI** - Terraform script uses AWS CLI to manage AWS resources.
* **Redshift Serverless Cluster** - Redshift Serverless Workgroup and namespace that contains a database with a table named Employee

## Deploy Demo

1. Clone the repo onto your local development machine using `git clone <repo url>`.
2. Change directory to demo repository and terraform directory.

```
cd confluent-to-redshift-upserts/Terraform

```
3. Use Terraform CLI to deploy solution

```
terraform plan

terraform apply

```
