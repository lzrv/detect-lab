# Use Debian 12.2 as the base image
FROM debian:12.2

# Install OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk

# Install curl and wget
RUN apt-get install -y curl wget

# Download and include synopsys-detect-9.1.0.jar
RUN mkdir /opt/synopsys && \
    wget -O /opt/synopsys/synopsys-detect-9.1.0.jar \
    https://sig-repo.synopsys.com/artifactory/bds-integrations-release/com/synopsys/integration/synopsys-detect/9.1.0/synopsys-detect-9.1.0.jar

# Clone the Tiredful-API repository
RUN apt-get install -y git && \
    git clone https://github.com/payatu/Tiredful-API /opt/tiredful-api

# Set the working directory
WORKDIR /opt/synopsys

# Copy the application.properties file to the working directory
COPY application.properties .

# Command to run when the container starts
CMD ["java", "-jar", "synopsys-detect-9.1.0.jar"]
