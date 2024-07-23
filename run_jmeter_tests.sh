#!/bin/bash

# Start the services
docker-compose up -d


# Load the data dump to the new test db
docker exec --interactive --tty neo4j-service neo4j-admin database load test --from-path=/var/lib/neo4j/import/ 

# Create the test db
docker exec --interactive --tty neo4j-service cypher-shell -u neo4j -p testpassword --file /var/lib/neo4j/import/cypher/createTestDb.cypher

# Access the JMeter container
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
