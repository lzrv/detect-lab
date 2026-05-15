FROM fedora:44

RUN dnf update -y && \
    dnf install -y git curl wget vim zip unzip tar java-21-openjdk-devel which findutils procps-ng && \
    dnf clean all

RUN mkdir /opt/blackduck && \
    wget -O /opt/blackduck/detect-11.4.2.jar \
    https://repo.blackduck.com/bds-integrations-release/com/blackduck/integration/detect/11.4.2/detect-11.4.2.jar

RUN dnf install -y nodejs npm && dnf clean all

RUN npm install -g pnpm yarn lerna

RUN dnf install -y python3 python3-pip python3-devel && dnf clean all

RUN pip3 install --no-cache-dir pipenv poetry uv

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh

ENV PATH="/opt/miniconda/bin:$PATH"

RUN dnf install -y maven && dnf clean all

ARG GRADLE_VERSION=8.13
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /tmp/gradle.zip && \
    unzip -q /tmp/gradle.zip -d /opt && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle && \
    rm /tmp/gradle.zip

RUN curl -fL https://github.com/sbt/sbt/releases/download/v1.10.11/sbt-1.10.11.tgz | tar -xz -C /opt && \
    ln -s /opt/sbt/bin/sbt /usr/local/bin/sbt

RUN dnf install -y golang && dnf clean all

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

ENV PATH="/root/.cargo/bin:$PATH"

RUN curl -sSL https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo \
    -o /etc/yum.repos.d/microsoft-prod.repo

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y dotnet-sdk-9.0 && \
    dnf clean all

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
