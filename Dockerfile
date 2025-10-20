FROM golang

# Update our image
RUN echo "Updating base container" && \
    apt-get -y update && \
    apt-get -y install zip python3 python3-pip vim jq lsb-release software-properties-common ipcalc && \
    apt-get -y upgrade && \
    pip install awscli --break-system-packages && \
    apt-get clean all && \
    echo "Installing tfenv" && \
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    ln -s ~/.tfenv/bin/* /usr/local/bin && \
    echo "Installing tgenv" && \
    git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv && \
    ln -s ~/.tgenv/bin/* /usr/local/bin && \
    echo "Installing SOPS" && \
    go install go.mozilla.org/sops/v3/cmd/sops@v3.7.3

RUN tfenv install 1.7.5 && \
    tfenv use 1.7.5 && \
    tgenv install 0.81.1 

WORKDIR /root/repo