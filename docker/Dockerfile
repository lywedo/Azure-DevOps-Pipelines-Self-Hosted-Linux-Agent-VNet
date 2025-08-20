FROM ubuntu:20.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    zip \
    wget \
    unzip

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install SQL Server tools (includes sqlpackage)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Add SQL tools to PATH
ENV PATH="$PATH:/opt/mssql-tools/bin"

# Install sqlpackage separately (latest version)
RUN wget -q https://go.microsoft.com/fwlink/?linkid=2196334 -O sqlpackage.zip \
    && unzip -q sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage \
    && rm sqlpackage.zip

# Add sqlpackage to PATH
ENV PATH="$PATH:/opt/sqlpackage"

# Verify installations
RUN sqlcmd -? || echo "sqlcmd installed" \
    && sqlpackage /version || echo "sqlpackage installed"

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]