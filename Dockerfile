FROM fedora:44

RUN dnf update -y && \
    dnf install -y git curl wget vim zip unzip tar java-21-openjdk-devel which findutils procps-ng && \
    dnf clean all

RUN mkdir /opt/blackduck && \
    wget -O /opt/blackduck/detect-11.4.2.jar \
    https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/detect/11.4.2/detect-11.4.2.jar

RUN dnf install -y nodejs npm && dnf clean all

RUN npm install -g pnpm yarn lerna

# Clone the Tiredful-API repository
RUN git clone https://github.com/payatu/Tiredful-API \
    /opt/scan_targets/tiredful-api

# Clone detect source code
RUN git clone https://github.com/blackducksoftware/detect \
    /opt/scan_targets/detect

# Clone Express.js as a sample NPM project for NPM detector testing
RUN git clone https://github.com/expressjs/express \
    /opt/scan_targets/express

# Set the working directory
WORKDIR /opt/blackduck

# Copy the application.properties file to the working directory
COPY application.properties .

# Copy detect.sh
COPY detect.sh .

RUN chmod u+x detect.sh

# CMD ["java", "-jar", "detect-11.4.2.jar"]
