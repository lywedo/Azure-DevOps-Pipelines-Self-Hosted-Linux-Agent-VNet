FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
    apt-transport-https apt-utils ca-certificates curl git iputils-ping jq lsb-release \
    software-properties-common zip wget unzip gnupg \
 && rm -rf /var/lib/apt/lists/*

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# SQL tools (sqlcmd)
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="$PATH:/opt/mssql-tools/bin"

# .NET 9 SDK + sqlpackage (Linux)
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y dotnet-sdk-9.0 \
 && rm -rf /var/lib/apt/lists/* \
 && dotnet tool install -g microsoft.sqlpackage

ENV PATH="$PATH:/root/.dotnet/tools"

# Optional: display versions (non-fatal if sqlpackage prints help)
RUN sqlcmd -? >/dev/null 2>&1 || true \
 && sqlpackage /Version || true \
 && dotnet --info

ENV TARGETARCH=linux-x64 \
    AGENT_ALLOW_RUNASROOT=1

WORKDIR /azp
COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]