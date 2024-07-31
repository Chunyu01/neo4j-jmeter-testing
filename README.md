# Integration Testing with JMeter and Neo4j in a Docker Environment

**Document Author:** Chunyu Wilson (Neo4j)
**Date:** July 23,2024 
**Version:** 1.0

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

### 3. Write the Cypher Script

Create a Cypher script (`createTestDb.cypher`) in the `neo4j/import` directory. This script should contain the necessary commands to set up your test database schema and data.

### 4. Run the Integration Tests

Execute the `run_jmeter_tests.sh` script to start the integration testing process. This script performs the following steps:

- Starts the Docker services defined in `docker-compose.yml`.
- Loads the data dump into the new test database.
- Creates the test database using the Cypher script.
- Accesses the JMeter container and runs the JMeter test plan, saving the results in the `jmeter/report` directory.
  
### 5.Using an External Cypher Query File in JMeter
To use an external Cypher query file in your JMeter Test Plan, follow these steps:

- Ensure the external Cypher query file (e.g., query.cypher) is accessible from the machine where JMeter is running.
- In the test plan file, use the function `${__FileToString(query.cypher,,)}` to read the content of the Cypher query file.
- Ensure the path to the Cypher query file is correct. If the file is in the same directory as the JMeter test plan, you can use just the file name. Otherwise, provide the full path.

## Script Details
The `run_jmeter_tests.sh` script includes detailed commands for each step. You can find the script [here](./run_jmeter_tests.sh).

### Summary of Steps

1. **Start the Docker Services:** Uses `docker-compose up -d` to start the defined services.
2. **Load Data Dump:** Loads the data dump into a new test database.
3. **Create Test Database:** Runs the Cypher script to set up the test database.
4. **Run JMeter Test Plan:** Accesses the JMeter container and executes the test plan, saving the results with a timestamp.

## Running the Tests in CI/CD

### Shell Script

Configure your CI/CD pipeline to execute the `run_jmeter_tests.sh` script. Ensure the pipeline is set up to handle Docker commands and has the necessary permissions to start and interact with Docker containers.

The shell script starts the Neo4j database and creates the test database by using Docker Compose to bring up the Neo4j service, waiting for it to be ready, and then running a Cypher script to set up the database schema and data. The script ensures that the Neo4j instance is fully operational before proceeding with the database setup.

### GitHub Workflow Pipeline

The CI/CD pipeline, defined in the `ci-cd.yml` file, automates the process of building and testing your Neo4j database with JMeter. It checks out the repository, sets up Docker Buildx, logs in to Docker Hub, builds and pushes Docker images, starts Docker Compose services, waits for Neo4j to be ready, downloads the Neo4j data dump, loads the data dump into Neo4j, restarts the Neo4j container, waits for Neo4j to be ready again, runs JMeter tests, copies JMeter test results to the host, lists the contents of the JMeter report directory, and uploads the JMeter test results as an artifact.

## Viewing Test Results

After the tests have run, you can find the test results in the `jmeter/report` directory. The results are saved with a timestamp to help you track the execution history.



