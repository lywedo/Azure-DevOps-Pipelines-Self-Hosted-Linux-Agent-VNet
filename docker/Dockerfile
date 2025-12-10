FROM ubuntu:24.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssl

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
    python3-pip

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Fix CVE-2024-47081: Upgrade requests library to 2.32.4 or later
# Fix CVE-2023-37920: Upgrade certifi to 2023.7.22 or later (removes e-Tugra root certificates)
# Fix CVE-2025-66418: Upgrade urllib3 to 2.6.0 or later (fixes unbounded decompression DoS)
# Fix CVE-2024-3651: Upgrade idna to 3.7 or later (fixes quadratic complexity DoS in encode())
RUN pip3 install --upgrade 'requests>=2.32.4' 'certifi>=2023.7.22' 'urllib3>=2.6.0' 'idna>=3.7' --break-system-packages

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]