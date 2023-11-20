# confluent-to-redshift-upserts

Amazon Redshift does not support upsert command. Therefore, the recommended way to handle upserts is using [Merge operation](https://docs.aws.amazon.com/redshift/latest/dg/t_updating-inserting-using-staging-tables-.html). This entails creating a staging table containing all the new or updated records and subsequently utilizing the Merge command to merge the staging table with the target table. It's important to note that while this approach is effective, it may not be optimal for real-time use cases.

As an alternative, individual updates can be executed using the UPDATE command. However, this method is not recommended for large-scale or batch operations due to its lack of batching support, potentially making it an expensive operation.

This demo showcases the utilization of a Lambda function to manage row-level updates in a Redshift Serverless cluster. The function reads input events from a Confluent Cloud topic and leverages the UPDATE command and [Redshift Data API](https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html) to perform row updates/Inserts within Redshift.

```
├── terraform                             <-- Demo terraform script and artifacts
│   ├── terraform.tf                      <-- Terraform for AWS resources
│   ├── redshift_upsert_lambda.zip        <-- Zip file for upsert lambda function code.
```

## General Requirements

* **Confluent Cloud Cluster and API Keys** - API Keys should be added to Secrets Manager. For more information, check [this](https://docs.aws.amazon.com/msk/latest/developerguide/msk-password.html) out.
* **Terraform (0.14+)** - The application is automatically created using [Terraform](https://www.terraform.io). Besides having Terraform installed locally, will need to provide your cloud provider credentials so Terraform can create and manage the resources for you.
* **AWS CLI** - Terraform script uses AWS CLI to manage AWS resources.
* **Redshift Serverless Cluster** - Redshift Serverless Workgroup and namespace that contains a database with a table named Employee.

## Deploy Demo

1. Clone the repo onto your local development machine using `git clone <repo url>`.
2. Change directory to demo repository and terraform directory.

```
cd confluent-to-redshift-upserts/terraform

```
3. Use Terraform CLI to deploy solution

```
terraform plan

terraform apply

```

## How does it work?

The demo expects a Kafka record in this format:
* **employee_id**: An integer representing the unique identifier for the employee.
* **employee_name**: A string representing the name of the employee.
* **employee_age**: An integer representing the age of the employee.

This is a sample record
```json
{
  "employee_id": 54,
  "employee_name": "Zamzam",
  "employee_age": 35
}
```
1. Once this event is written to the Confluent topic, the event source mapping triggers the lambda function
2. The lambda function uses Redshift Data API to either update an existing row or insert a new row.


