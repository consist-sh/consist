name "Setup Docker"

shell do
  <<~EOS
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl gnupg -y
    install -m 0755 -d /etc/apt/keyrings
    [[ -f /etc/apt/keyrings/docker.gpg]] && rm /etc/apt/keyrings/docker.gpg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --no-tty --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    # Install Docker
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Make Docker start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
  EOS
end

shell "Create docker group", params: {raise_on_non_zero_exit: false} do
  <<~EOS
    # Create group
    sudo groupadd docker
    sudo usermod -aG docker $USER
  EOS
end

shell "Create default private network", params: {raise_on_non_zero_exit: false} do
  <<~EOS
    # Create default private network
    docker network create private
  EOS
end
