FROM jenkins/jenkins:lts

USER root

# Install AWS CLI and Docker CLI
RUN apt-get update && apt-get install -y \
    curl unzip docker.io

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Ensure docker group uses host's GID (991) and add jenkins user to it
RUN groupmod -g 991 docker || groupadd -g 991 docker && \
    usermod -aG docker jenkins

USER jenkins

