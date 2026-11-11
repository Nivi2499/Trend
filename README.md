\# Trend - DevOps CI/CD Deployment Project



\## 1. Project Overview



This project demonstrates an end-to-end DevOps deployment workflow using Docker, DockerHub, Terraform, AWS EKS, Kubernetes, Jenkins, and GitHub Webhooks.



The application is containerized using Docker and deployed to an AWS EKS cluster through an automated Jenkins CI/CD pipeline.



\## 2. Technologies Used



\- AWS EC2

\- AWS EKS (Elastic Kubernetes Service)

\- Terraform

\- Docker

\- DockerHub

\- Kubernetes

\- Jenkins

\- GitHub

\- Nginx

\- PowerShell



\## 3. Project Architecture



1\. Source code and configuration are maintained in GitHub.

2\. GitHub Webhook notifies Jenkins whenever code is pushed.

3\. Jenkins checks out the latest code.

4\. Jenkins builds a Docker image.

5\. Jenkins authenticates with DockerHub and pushes the image.

6\. Jenkins connects to AWS EKS.

7\. Kubernetes deploys the updated application.



\## 4. Docker Configuration



The application is packaged using a Dockerfile based on Nginx Alpine.



\- Application port: 3000

\- DockerHub repository: nivi99/trend-app

\- Image tags are generated using the Jenkins build number.



\## 5. Kubernetes Deployment



The application is deployed to the Kubernetes namespace:



`trend`



Deployment details:



\- Deployment name: trend-app

\- Replicas: 1

\- Container port: 3000

\- Deployment strategy: Recreate

\- Service name: trend-service

\- Service type: ClusterIP

\- Service port: 3000



\## 6. Jenkins CI/CD Pipeline



The Jenkins pipeline includes the following stages:



1\. Checkout

2\. Build Docker Image

3\. Push to DockerHub

4\. Deploy to AWS EKS



The pipeline automatically builds and deploys the application whenever changes are pushed to the GitHub main branch.



\## 7. GitHub Webhook Integration



A GitHub Webhook is configured to notify Jenkins about push events.



This enables automatic pipeline execution without manually starting a Jenkins build.



\## 8. Application Access



The application can be accessed locally using Kubernetes port forwarding:



```bash

kubectl port-forward svc/trend-service 3001:3000 -n trend

```



Open the following address in your browser:



`http://localhost:3001`



\## 9. Repository Structure



```text

Trend/

|

|-- dist/

|-- k8s/

|   |-- deployment.yaml

|-- Dockerfile

|-- nginx.conf

|-- Jenkinsfile

|-- main.tf

|-- README.md

|-- .gitignore

|-- .dockerignore

```



\## 10. Project Outcome



Successfully completed:



\- Docker image creation and DockerHub push.

\- AWS infrastructure provisioning using Terraform.

\- Kubernetes application deployment on AWS EKS.

\- Jenkins CI/CD pipeline configuration.

\- GitHub Webhook integration.

\- Automated build and deployment verification.

\- Application access through the browser.



This project demonstrates an end-to-end automated DevOps deployment workflow.

