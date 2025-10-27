FROM golang

# Update our image
RUN <<EOF
    echo "Updating base container"
    apt-get -y update
    apt-get -y install zip python3 python3-pip vim jq lsb-release
    apt-get -y upgrade
    pip install awscli --break-system-packages
    apt-get clean all
    echo "Installing node version manager"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    echo "Installing tenv"
    DKPG_VERSION=$(dpkg --print-architecture)
    LATEST_VERSION=$(curl --silent https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name)
    curl -O -L "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${LATEST_VERSION}_${DKPG_VERSION}.deb"
    dpkg -i "tenv_${LATEST_VERSION}_${DKPG_VERSION}.deb"
    echo "Installing SOPS"
    go install github.com/getsops/sops/v3/cmd/sops@v3.11.0
    echo "Installing packer"
    wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install packer
EOF

RUN <<EOF
    tenv tofu install 1.10.6
    tenv tofu use 1.10.6
    tenv terragrunt install 0.91.5
    tenv terragrunt use 0.91.5
    bash -c "source ~/.bashrc && nvm install 20"
    echo 'alias tf="tofu"' >> ~/.bashrc
    echo 'alias tfi="tofu init"' >> ~/.bashrc
    echo 'alias tfp="tofu plan"' >> ~/.bashrc
    echo 'alias tfa="tofu apply"' >> ~/.bashrc
    echo 'alias tfd="tofu destroy"' >> ~/.bashrc
    echo 'alias tg="terragrunt"' >> ~/.bashrc
    echo 'alias tgi="terragrunt init"' >> ~/.bashrc
    echo 'alias tgp="terragrunt plan"' >> ~/.bashrc
    echo 'alias tga="terragrunt apply"' >> ~/.bashrc
    echo 'alias tgd="terragrunt destroy"' >> ~/.bashrc
    echo 'alias ll="ls -alh"' >> ~/.bashrc
EOF

WORKDIR /root/repo