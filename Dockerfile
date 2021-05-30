FROM ubuntu:20.04

#Install Dependencies
RUN set -xv;\
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3.8 python3-pip sshpass curl gnupg-agent vim && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata && \
    apt-get install -y apt-transport-https ca-certificates software-properties-common

# Install Helm
RUN set -xv;\
    mkdir helm &&\
    curl -L https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz -o helm.tar.gz && \
    tar xvf helm.tar.gz -C helm && \
    mv helm/linux-amd64/helm usr/local/bin/helm3 && \
    rm -rf helm

# Install Helm Push
RUN set -xv;\
    mkdir helmpush && \
    curl -L https://github.com/chartmuseum/helm-push/releases/download/v0.9.0/helm-push_0.9.0_linux_amd64.tar.gz -o helmpush.tar.gz && \
    tar xvf helmpush.tar.gz -C helmpush && \
    mv helmpush/bin/helmpush /usr/local/bin && \
    rm -rf helmpush

# Install Pip Dependencies
RUN set -xv;\
    python3 --version && \
    pip3 install --no-cache-dir ansible==2.10.6 && \
    pip3 install --no-cache-dir jmespath==0.10.0 && \
    pip3 install --no-cache-dir openshift==0.11.2 && \
    pip3 install --no-cache-dir kubernetes==11.0.0 && \
    pip3 install --no-cache-dir requests==2.22.0 && \
    pip3 install --no-cache-dir netaddr==0.8.0 && \
    pip3 install --no-cache-dir pexpect==4.8.0 && \
    ansible-galaxy collection install community.kubernetes:==1.1.1

# Install Docker
RUN set -xv;\
    apt-get install -y sudo && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" && \
    apt-get update && \
    apt-get install -y \
    docker-ce=5:20.10.3~3-0~ubuntu-focal \
    docker-ce-cli=5:20.10.3~3-0~ubuntu-focal \
    containerd.io=1.4.3-1 && \
    sudo usermod -aG docker $(whoami) && \
    sudo usermod -aG docker jenkins

# Install Java for Jenkins
RUN set -xv;\
    apt-get install -y default-jdk-headless

# Install Jenkins
RUN set -xv;\
    curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://pkg.jenkins.io/debian-stable binary/" && \
    apt-get update && \
    apt-get install jenkins -y

# Set Jenkins Port and HOME
EXPOSE 8080/tcp
ENV JENKINS_HOME=/var/lib/jenkins

COPY entrypoint.sh /
ENTRYPOINT /entrypoint.sh
CMD /bin/bash --login
