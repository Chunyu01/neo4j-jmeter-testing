# Integration Testing with JMeter and Neo4j in a Docker Environment

## Overview

This guide provides detailed instructions on how to use a Docker container for running integration tests with JMeter for a Neo4j database. The setup is designed to be executed within a CI/CD process, ensuring smooth and automated testing of your Neo4j database interactions.

## Prerequisites

- Docker installed on your machine.
- Understanding of Docker, JMeter, Neo4j and shell scripts.

## Project Structure

The project directory should have the following structure:

```plaintext
JMeterTest/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── jmeter/
│   ├── report/
│   ├── jmeter.log
│   ├── movies_test_plan.jmx
│   └── query.cypher
├── neo4j/
│   ├── data/
│   │   └── import/
│   │       └── neo4j.dump
├── docker-compose.yml
├── Dockerfile
├── README.md
└── run_jmeter_tests.sh

```

## Step-by-Step Instructions

### 1. Prepare Docker Compose File

Ensure your `docker-compose.yml` file is correctly configured to define the services for Neo4j and JMeter. The Neo4j service should expose the necessary ports and mount volumes for data import and export.

### 2. Prepare the JMeter Test Plan

Place your JMeter test plan (`movies_test_plan.jmx`) in the `jmeter` directory. This test plan should define the interactions with your Neo4j database.

#### Using an External Cypher Query File in JMeter

To use an external Cypher query file in your JMeter Test Plan, follow these steps:

- Ensure the external Cypher query file (e.g., query.cypher) is accessible from the machine where JMeter is running.
- In the test plan file, use the function `${__FileToString(query.cypher,,)}` to read the content of the Cypher query file.
- Ensure the path to the Cypher query file is correct. If the file is in the same directory as the JMeter test plan, you can use just the file name. Otherwise, provide the full path.


### 3. Run the Integration Tests in CI/CD

#### Shell Script

Configure your CI/CD pipeline to execute the `run_jmeter_tests.sh` script. Ensure the pipeline is set up to handle Docker commands and has the necessary permissions to start and interact with Docker containers.

Execute the `run_jmeter_tests.sh` script to start the integration testing process. This script performs the following steps:

1. **Start the Docker Services**: Uses `docker-compose up -d` to start the defined services.
2. **Wait for Neo4j to be Ready**: Waits until the Neo4j service is fully operational.
3. **Stop the Neo4j Database**: Stops the Neo4j database using Cypher shell.
4. **Load Data Dump**: Loads the data dump into Neo4j using `neo4j-admin`.
5. **Start the Neo4j Database**: Starts the Neo4j database using Cypher shell.
6. **Wait for the Test Database to be Online**: Ensures the test database is online before running tests.
7. **Run JMeter Test Plan**: Accesses the JMeter container, runs the test plan, and saves the results with a timestamp.
   

#### GitHub Workflow Pipeline

The CI/CD pipeline, defined in the `ci-cd.yml` file, automates the process of building and testing your Neo4j database with JMeter. It includes:

1. **Checking out the repository**.
2. **Setting up Docker Buildx**.
3. **Logging in to Docker Hub**.
4. **Building and pushing Docker images**.
5. **Starting Docker Compose services**.
6. **Waiting for Neo4j to be ready**.
7. **Downloading the Neo4j data dump**.
8. **Loading the data dump into Neo4j**.
9. **Restarting the Neo4j container**.
10. **Waiting for Neo4j to be ready again**.
11. **Running JMeter tests**.
12. **Copying JMeter test results to the host**.
13. **Listing the contents of the JMeter report directory**.
14. **Uploading the JMeter test results as an artifact**.

## Viewing Test Results

After the tests have run, you can find the test results in the `jmeter/report` directory. The results are saved with a timestamp to help you track the execution history.
