# Introduction

This file describes the project that has as a goal the following

1. Deploy an Application on Azure (Use Free Account)

- Create an Azure App Service that connects to a MySQL or PostgreSQL database using a private endpoint.

- The application should have a basic UI that interacts with the database (e.g., storing and retrieving data).

- Provide a simple web application (Node.js, Python, or any preferred language).

- Implement a test that verifies the database connection.

- All these Azure Resources should be created thought Infrastructure as Code (Terraform)

 

3. Containerization

- Package the application into a Docker image.

- Provide a Dockerfile to build and run the application locally.

- Run the application in a Docker container to ensure functionality.

 

4. Infrastructure as Code (Terraform)

- Write a Terraform script that allows the infrastructure to be deployed in different environments (e.g., dev, staging, production).

- The script should provision:

    - Azure App Service

    - Azure Database (MySQL/PostgreSQL)

    - Vnet, Subnets

    - Private Endpoint

- Ensure variables can be used for different configurations.

 

5. CI/CD Pipeline (Use Free Account)

Create a GitLab CI/CD or GitHub Actions pipeline to automate the following:

- Build and push the Docker image to a container registry (Azure Container Registry or Docker Hub).

- Deploy the Terraform infrastructure.

- Deploy the application to Azure App Service.

- Run some simple tests to verify the application.

# Assumptions

My assumptions for the project are:

- PostgreSQL database is a managed PostgreSQL instance (Flexible Server)
- Basic UI that interacts with the database is Swagger
- Application is a Python, FastAPI application
- Storage Account for tfstate and Azure Container Registry are shared resources across dev, staging and prod and they are deployed manually upfront
- Storage Account and Container registry are deployed with public access enabled for simplification

# Application (backend folder)



# Containerization (backend folder - Dockerfile)

# IaaC (terraform folder)

Initialize 
tofu init -backend-config=/mnt/e/src/pg-tech-assesment/terraform/environments/dev/backend.tfbackend -reconfigure





# CI CD Pipeline

## CI

## CD

Deploy infra 
1. Initialize tf 

tofu init -backend-config="environments/prod/backend.tfbackend"

2. tofu plan
tofu plan -var-file="/mnt/e/src/pg-tech-assesment/terraform/environments/dev/terraform.tfvars" 
3. tofu apply


Deploy WebApp


# Run code manually

- I am assuming the development machine is running Ubuntu

1. Make sure docker is installed


if it isn't run the following script

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

2. Build the local docker image

```bash
docker build -t fastapi-test:0.0.1 .
```

3. Test if the image is available

```bash
docker image list
```
you should see something like this

```
REPOSITORY     TAG       IMAGE ID       CREATED          SIZE
fastapi-test   latest    1a90358b749b   26 seconds ago   180MB
```

4. Run the docker container

You'll need to run the docker container and pass the DATABASE_URL environment variable. 

Make sure that the database connection string has the following format

```
postgresql+asyncpg://<postgres-user>:<postgres-password>@<database-url>/<database-name>
```

The database needs to pre-exist with proper schema.

It needs to have a table called 'records' with the following columns
- id (uuid)
- name (text)
- value (text)
- created_at (timestap with timezone)
- updated__at (timestamp with timezone)

Once the prerequisites are met you can the following command

```bash

docker run -e DATABASE_URL=<your_database_url> -p 8000:8000 fastapi-test:0.0.1
```

postgresql+asyncpg://postgres:Patryk96!@gielniak-pg-dev.privatelink.postgres.database.azure.com/records_db
gielniak-pg-dev.privatelink.postgres.database.azure.com

The container will have port 8000 mapped to your local port 8000 so you can test the application by calling the 'test-database-connection' endpoint

```bash
curl -X 'GET' \
  'http://localhost:8000/test-db-connection' \
  -H 'accept: application/json'

```

or open http://localhost:8000/docs - to interact with the API via Swagger

# Push the code to container registry

az login
az acr login --name gielniakacr

