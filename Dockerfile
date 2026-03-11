# Use Debian 13 (trixie) as the base image
FROM debian:trixie

# Install OpenJDK 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk

# Install zip, curl, and wget
RUN apt-get install -y zip curl wget

# Install vim
RUN apt-get install -y vim

# Install Node.js and npm for NPM detector testing
RUN apt-get install -y nodejs npm

# Download and include detect-11.2.1.jar
RUN mkdir /opt/blackduck && \
    wget -O /opt/blackduck/detect-11.2.1.jar \
    https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/detect/11.2.1/detect-11.2.1.jar

# Clone the Tiredful-API repository
RUN apt-get install -y git && \
    git clone https://github.com/payatu/Tiredful-API \
	/opt/scan_targets/tiredful-api

# Clone synopsys-detect source code
RUN git clone https://github.com/blackducksoftware/synopsys-detect \
	/opt/scan_targets/synopsys-detect

# Set the working directory
WORKDIR /opt/blackduck

# Copy the application.properties file to the working directory
COPY application.properties .

# Copy detect.sh
COPY detect.sh .

RUN chmod u+x detect.sh

# CMD ["java", "-jar", "detect-11.2.1.jar"]
