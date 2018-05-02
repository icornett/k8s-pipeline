FROM jenkinsci/slave

# Set Workdir to /tmp for downloading files, then su to root
WORKDIR /tmp
USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    apt-utils \
    wget \
    curl \
    unzip \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    python3 \
    python3-pip

# Download and install Terraform 0.11.7
RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip && \
    unzip -j terraform_0.11.7_linux_amd64.zip && \
    mv terraform /usr/bin/terraform

RUN pip3 install --upgrade pip

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.5 50 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 40

USER jenkins
WORKDIR /home/jenkins
