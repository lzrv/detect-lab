FROM --platform=linux/amd64 fedora:44

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

RUN curl -sSLf https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/prod.repo \
    -o /etc/yum.repos.d/microsoft-prod.repo

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y dotnet-sdk-9.0 && \
    dnf clean all

RUN dnf install -y ruby ruby-devel rubygems && dnf clean all

RUN gem install bundler

RUN dnf install -y php php-cli php-json && dnf clean all

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pip3 install --no-cache-dir conan

ARG DART_VERSION=3.7.3
RUN wget -q "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/linux_packages/dart_${DART_VERSION}-1_amd64.rpm" \
        -O /tmp/dart.rpm && \
    rpm -i /tmp/dart.rpm && \
    rm /tmp/dart.rpm

RUN dnf install -y erlang && dnf clean all

RUN wget -q https://s3.amazonaws.com/rebar3/rebar3 -O /usr/local/bin/rebar3 && \
    chmod +x /usr/local/bin/rebar3

RUN dnf install -y opam && dnf clean all

RUN opam init --disable-sandboxing -y

ENV PATH="/root/.opam/default/bin:$PATH"

RUN dnf install -y perl perl-CPAN perl-App-cpanminus && dnf clean all

RUN dnf install -y R && dnf clean all

ARG BAZEL_VERSION=8.2.1
RUN wget -q "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64" \
        -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Swift (~2 GB layer) — uncomment to enable
# ARG SWIFT_VERSION=6.1
# RUN wget -q "https://download.swift.org/swift-${SWIFT_VERSION}-release/ubi9/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubi9.tar.gz" \
#         -O /tmp/swift.tar.gz && \
#     tar -xz -C /opt -f /tmp/swift.tar.gz && \
#     ln -s /opt/swift-${SWIFT_VERSION}-RELEASE-ubi9/usr/bin/swift /usr/local/bin/swift && \
#     rm /tmp/swift.tar.gz

# Bitbake/Yocto — not installed; Yocto setup is impractical in a general container.
# See scan_targets/bitbake/README.md for manual setup instructions.

RUN git clone --depth=1 https://github.com/expressjs/express /opt/scan_targets/npm/express
RUN git clone --depth=1 https://github.com/vitejs/vite /opt/scan_targets/pnpm/vite
RUN git clone --depth=1 https://github.com/facebook/jest /opt/scan_targets/yarn/jest
RUN git clone --depth=1 https://github.com/psf/requests /opt/scan_targets/pip/requests
RUN git clone --depth=1 https://github.com/python-poetry/poetry /opt/scan_targets/poetry/poetry
RUN git clone --depth=1 https://github.com/pypa/pipenv /opt/scan_targets/pipenv/pipenv
RUN git clone --depth=1 https://github.com/astral-sh/uv /opt/scan_targets/uv/uv
RUN git clone --depth=1 https://github.com/Anaconda-Platform/anaconda-client /opt/scan_targets/conda/anaconda-client
RUN git clone --depth=1 https://github.com/spring-projects/spring-petclinic /opt/scan_targets/maven/spring-petclinic
RUN git clone --depth=1 https://github.com/square/okhttp /opt/scan_targets/gradle/okhttp
RUN git clone --depth=1 https://github.com/scala/scala-parser-combinators /opt/scan_targets/sbt/scala-parser-combinators
RUN git clone --depth=1 https://github.com/cli/cli /opt/scan_targets/go/cli
RUN git clone --depth=1 https://github.com/sharkdp/bat /opt/scan_targets/cargo/bat
RUN git clone --depth=1 https://github.com/dotnet-architecture/eShopOnWeb /opt/scan_targets/nuget/eShopOnWeb
RUN git clone --depth=1 https://github.com/sinatra/sinatra /opt/scan_targets/gemfile/sinatra
RUN git clone --depth=1 https://github.com/laravel/laravel /opt/scan_targets/composer/laravel
RUN git clone --depth=1 https://github.com/conan-io/examples /opt/scan_targets/conan/examples
RUN git clone --depth=1 https://github.com/dart-lang/pub /opt/scan_targets/dart/pub
RUN git clone --depth=1 https://github.com/abseil/abseil-cpp /opt/scan_targets/bazel/abseil-cpp
RUN git clone --depth=1 https://github.com/ninenines/cowboy /opt/scan_targets/erlang/cowboy
RUN git clone --depth=1 https://github.com/mirage/mirage /opt/scan_targets/ocaml/mirage
RUN git clone --depth=1 https://github.com/libwww-perl/libwww-perl /opt/scan_targets/perl/libwww-perl
RUN git clone --depth=1 https://github.com/rstudio/shiny /opt/scan_targets/r/shiny

# Set the working directory
WORKDIR /opt/blackduck

# Copy the application.properties file to the working directory
COPY application.properties .

# Copy scan.sh
COPY scan.sh .

RUN chmod +x scan.sh

# CMD ["java", "-jar", "detect-11.4.2.jar"]
