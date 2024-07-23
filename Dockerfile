# Use an official openjdk runtime as a parent image
FROM openjdk:11-jre-slim

# Set the JMeter version
ARG JMETER_VERSION=5.6.3

# Install necessary packages and clean up
RUN apt-get update \
    && apt-get install -y wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Download and unzip JMeter
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip \
    && unzip apache-jmeter-${JMETER_VERSION}.zip \
    && rm apache-jmeter-${JMETER_VERSION}.zip \
    && mv apache-jmeter-${JMETER_VERSION} /opt/jmeter

# Set JMeter home environment variable
ENV JMETER_HOME /opt/jmeter
ENV PATH $JMETER_HOME/bin:$PATH

# Set the working directory
WORKDIR $JMETER_HOME

# Default command to run JMeter
ENTRYPOINT ["jmeter"]
CMD ["-h"]

# Expose the port if you need to use JMeter in server mode
# EXPOSE 1099
