FROM jenkins/jenkins:lts
USER root

WORKDIR /tmp

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3 \
    python3-pip \
    wget \
    curl \
    unzip

RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip && \
    unzip -j terraform_0.11.7_linux_amd64.zip && \
    mv terraform /usr/bin/terraform

# Download and install Python3.6.5
#RUN wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz && \
#    tar xvf Python-3.6.5.tgz && \
#    cd Python-3.6.5 && \
#    ./configure --enable-optimizations && \
#    make -j8 && \
#    make install

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 50 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 40

WORKDIR /home/jenkins
USER jenkins