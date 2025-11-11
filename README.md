# Resilient Multi-Region AWS EKS Architecture

This repository contains a production-ready, multi-region, and highly-available AWS EKS deployment. It is designed to be resilient against single-region failures (like the recent AWS `us-east-1` outage) by running an active-active application across two different AWS regions (`ap-south-1` and `us-west-1`).

The entire infrastructure is provisioned as code using **Terraform**, and applications are deployed automatically via a **GitHub Actions** CI/CD pipeline using **Helm**.

This project focuses on the *application* and *ingress* layers. The database (MySQL) component is managed separately and is not part of this repository's automated deployment.

## 🚀 Key Features

* **High Availability & Disaster Recovery:** Survives a full regional AWS outage by automatically routing traffic to the healthy region.
* **Global Low Latency:** Uses **AWS Global Accelerator** to route users to the nearest application endpoint.
* **Infrastructure as Code (IaC):** The entire infrastructure (VPCs, EKS Clusters, IAM Roles, Global Accelerator) is defined in Terraform.
* **Automated Deployments:** A GitHub Actions workflow automatically builds, provisions, and deploys:
    1.  The AWS Infrastructure (Terraform)
    2.  The Cluster Controllers (Helm)
    3.  The Application (Helm)
* **Modern Kubernetes Ingress:** Uses the **AWS Load Balancer Controller** to provision **Network Load Balancers (NLBs)**, which then forward traffic to the **NGINX Ingress Controller** for L7 routing.

## 🏛️ Architecture Overview



This architecture ensures a seamless flow from the user to the application, with multiple layers of redundancy.

1.  **User -> DNS (GoDaddy):** The user accesses `employee.manojm.site`. A `CNAME` record in GoDaddy points to the Global Accelerator's static DNS name.
2.  **Global Accelerator (L4):** Receives the traffic and routes it to the nearest *healthy* endpoint. It monitors the health of the NLBs in both regions.
3.  **Network Load Balancer (NLB) (L4):** An NLB in each region (e.g., `ap-south-1`) receives the raw TCP traffic from the Global Accelerator.
4.  **NGINX Ingress Controller (L7):** The NLB forwards the traffic to the NGINX pods (managed by Helm). NGINX inspects the HTTP `Host` header (`employee.manojm.site`) to find the correct `Ingress` rule.
5.  **Application:** The `Ingress` rule routes the traffic to the `employee-directory` application `Service`, which finally sends it to the running pod.

## Prerequisites

Before you begin, you will need:

* An AWS Account.
* A domain name (e.g., `manojm.site`) managed in a provider like GoDaddy.
* An **S3 Bucket** to store the Terraform state.
* The following tools installed locally: `aws-cli`, `terraform`, `kubectl`, `helm`.

## 🛠️ Deployment Steps

This project is designed to be deployed entirely from the GitHub Actions workflow.

### 1. Configure GitHub Secrets

Fork this repository and add the following secrets in **Settings > Secrets and variables > Actions**:

* `AWS_ACCESS_KEY_ID`: Your AWS access key.
* `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.
* `AWS_REGION`: Your *default* AWS region (e.g., `ap-southeast-2` for your S3 backend).
* `PROJECT_NAME`: The name of your project (e.g., `employee-directory`).
* `TF_STATE_BUCKET`: The name of the S3 bucket you created for Terraform state.

### 2. Configure Terraform Backend

In the `infrastructure/backend.tf` file, update the `key` to match your project name and environment. The workflow in this repo uses a key structure based on environment variables.


### 3. Run the "Infrastructure-Creation" Job
The first job in the .github/workflows/deploy.yml pipeline provisions all the AWS infrastructure. It automatically does the following:

- Checks out the code.

- Configures AWS credentials.

- Runs terraform init with the correct backend configuration.

- Selects the stage or production workspace based on the Git branch.

- Runs terraform plan.

- Runs terraform apply to build:

- Two VPCs (primary and secondary)

- Two EKS Clusters

- The Global Accelerator

- The IAM Role for the AWS Load Balancer Controller

- The helm provider deployments for both AWS LBC and NGINX Ingress.

### 4. Run the "Multi-Cluster-Deployment" Job
This job runs automatically after the infrastructure is built. It uses a strategy: matrix to deploy your application to both clusters in parallel.

- It configures AWS credentials for each region in the matrix.

- It runs aws eks update-kubeconfig to connect kubectl to the correct cluster.

- It runs helm upgrade --install ... --set ingress.enabled=true to deploy the emp-dir-helm chart, which creates the Ingress resource.

🔑 Key Concepts & Solutions
This repository contains solutions to several complex "chicken-and-egg" problems in Terraform.

1. Finding the Helm-created NLB with Terraform
The Problem: How can our aws_globalaccelerator resource (in Terraform) get the ARN of the NLB, which is created later by the helm_release (via the AWS LBC)?

The Solution: We use a data "aws_lb" source that depends_on the helm_release. This data source uses the Kubernetes tag that the AWS LBC automatically adds to the NLB to find it. A time_sleep is added to win the race condition, giving the LBC time to create the NLB before Terraform searches for it.

Code (infrastructure/modules/helm/main.tf):

```Terraform

resource "helm_release" "ingress-nginx" {
  # ... (helm install config)
}

# Wait 90s for the AWS LBC to create the NLB
resource "time_sleep" "wait_for_nlb" {
  depends_on      = [helm_release.ingress-nginx]
  create_duration = "90s"
}

# Find the NLB by its unique tag
data "aws_lb" "aws_lb" {
  provider = aws
  depends_on = [time_sleep.wait_for_nlb]

  tags = {
    "kubernetes.io/service-name" = "ingress-nginx/ingress-nginx-controller"
  }
}
```
2. Adding AWS Tags to the Helm-created NLB
The Problem: We need to add our custom AWS tags (like Project and Environment) to the NLB, but the NLB is created by Helm, not Terraform.

The Solution: We add the aws-load-balancer-additional-resource-tags annotation to the helm_release set block. The AWS LBC reads this annotation and applies the tags to the NLB it creates.

Code (infrastructure/modules/helm/main.tf):

```Terraform

resource "helm_release" "ingress-nginx" {
  # ...
  set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
      value = "Environment=${terraform.workspace},Project=${var.project_name},ManagedBy=Terraform"
    }
  ]
}
```
3. Accessing the Application
After the pipeline succeeds, you must manually point your domain to the Global Accelerator.

Find the Global Accelerator DNS: Run terraform output global_accelerator_dns_name from the infrastructure directory (in the correct workspace) or find it in the AWS console.

Configure GoDaddy: Create a CNAME record:

Type: CNAME

Name: employee (or your subdomain)

Value: a1234abcd.awsglobalaccelerator.com (Your GA DNS Name)

Test: Your browser will send the wrong Host header, so test with curl:

Bash

curl -H "Host: employee.manojm.site" [http://a1234abcd.awsglobalaccelerator.com](http://a1234abcd.awsglobalaccelerator.com)
If this works, your GoDaddy CNAME will work once it propagates.