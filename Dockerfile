FROM ubuntu:latest

WORKDIR /src/app
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install \
    python3 \
    python3-pip \
    software-properties-common \
    wget \
    curl  \
    unzip -y

COPY ./requirements.txt /src/app
RUN pip install -r requirements.txt

RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /tmp/terraform && \
    mv /temp/terraform/terraform /usr/bin/terraform && \
    rm terraform.zip

CMD ["/bin/bash", "-c"]