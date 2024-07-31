#!/bin/bash

# Start the services
docker-compose up -d

# Function to wait for Neo4j to be ready
wait_for_neo4j() {
  echo "Waiting for Neo4j to be ready..."
  RETRIES=10
  until docker exec neo4j-service cypher-shell -u neo4j -p testpassword "RETURN 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "Waiting for Neo4j to start, $((RETRIES--)) remaining attempts..."
    sleep 10
  done

  if [ $RETRIES -eq 0 ]; then
    echo "Neo4j did not start in time"
    exit 1
  fi
  echo "Neo4j is up and running."
}

# Function to stop the neo4j db
stop_neo4j_db() {
  echo "Stoping database..."
  docker exec neo4j-service cypher-shell -u neo4j -p testpassword -d system "STOP DATABASE neo4j"
}


# Function to load the data dump to neo4j db
load_data_dump() {
  echo "Loading data dump to neo4j database..."
  docker exec neo4j-service neo4j-admin database load neo4j --from-path=/var/lib/neo4j/import/ --overwrite-destination=true
}

# Function to start the neo4j db
start_neo4j_db() {
  echo "Starting neo4j database..."
  docker exec neo4j-service cypher-shell -u neo4j -p testpassword -d system "START DATABASE neo4j"
}

# Function to wait for the neo4j db to be online
wait_for_test_db() {
  echo "Waiting for test database to be online..."
  RETRIES=10
  until docker exec neo4j-service cypher-shell -u neo4j -p testpassword "SHOW DATABASE neo4j YIELD name, currentStatus" | grep -E "online" || [ $RETRIES -eq 0 ]; do
    echo "Waiting for test database to be online, $((RETRIES--)) remaining attempts..."
    sleep 10
  done

  if [ $RETRIES -eq 0 ]; then
    echo "Test database did not come online in time"
    exit 1
  fi
  echo "Test database is online."
}

# Function to run JMeter test plan
run_jmeter_tests() {
  JMETER_CONTAINER_NAME="jmeter-service"
  if [ -z "$(docker ps --filter "name=$JMETER_CONTAINER_NAME" --format "{{.Names}}")" ]; then
    echo "JMeter container not found. Please check the docker-compose.yml file."
    exit 1
  fi

  echo "Accessing JMeter container..."
  docker exec $JMETER_CONTAINER_NAME sh -c "
    # Navigate to the JMeter test plan directory
    cd /jmeter || { echo 'JMeter directory not found.'; exit 1; }

    # Generate a timestamp
    timestamp=\$(date +\"%Y%m%d_%H%M%S\")

    # Ensure the report directory exists
    mkdir -p ./report

    # Define the report file name
    report_file=\"./report/test_results_\${timestamp}.jtl\"

    # Run JMeter test plan
    echo 'Running JMeter test plan...'
    jmeter -n -t movies_test_plan.jmx -l \${report_file}
    if [ \$? -ne 0 ]; then
      echo 'Failed to run JMeter test plan.'
      exit 1
    fi

    echo \"JMeter test completed successfully. Results saved to \${report_file}\"
  "
}

# Main script execution
wait_for_neo4j
stop_neo4j_db
load_data_dump
start_neo4j_db
wait_for_test_db
run_jmeter_tests
